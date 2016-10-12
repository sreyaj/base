#!/bin/bash -e

export ENABLED_MASTER_INTEGRATIONS=""
export AVAILABLE_SYSTEM_INTEGRATIONS=""
export ENABLED_SYSTEM_INTEGRATIONS=""

get_enabled_masterIntegrations() {
  __process_msg "GET-ing available master integrations from db"
  # TODO: after GET route is fixed, use filters only

  local api_url=""
  local api_token=$(cat $STATE_FILE | jq -r '.systemSettings.serviceUserToken')
  local api_url=$(cat $STATE_FILE | jq -r '.systemSettings.apiUrl')
  local master_integrations_get_endpoint="$api_url/masterIntegrations"

  local response=$(curl \
    -H "Content-Type: application/json" \
    -H "Authorization: apiToken $api_token" \
    -X GET $master_integrations_get_endpoint \
    --silent)
  response=$(echo $response | jq '.')
  local response_length=$(echo $response | jq '. | length')

  if [ $response_length -gt 5 ]; then
    ## NOTE: we're assuming we have at least 5 master integrations in global list

    ENABLED_MASTER_INTEGRATIONS=$(echo $response \
      | jq '[ .[] | select(.isEnabled==true and .level=="system") ]')
    local enabled_integrations_length=$(echo $ENABLED_MASTER_INTEGRATIONS | jq -r '. | length')
    __process_msg "Successfully fetched master integration list: $enabled_integrations_length"
  else
    local error=$(echo $response | jq '.')
    __process_msg "Error GET-ing master integration list: $error"
  fi
}

get_enabled_systemIntegrations() {
  __process_msg "GET-ing enabled system integrations from db"
  local api_token=$(cat $STATE_FILE | jq -r '.systemSettings.serviceUserToken')
  local api_url=$(cat $STATE_FILE | jq -r '.systemSettings.apiUrl')
  local system_integrations_get_endpoint="$api_url/systemIntegrations?isEnabled=true"

  local response=$(curl \
    -H "Content-Type: application/json" \
    -H "Authorization: apiToken $api_token" \
    -X GET $system_integrations_get_endpoint \
    --silent)
  response=$(echo $response | jq '.')

  AVAILABLE_SYSTEM_INTEGRATIONS=$(echo $response | jq '.')
  local available_integrations_length=$(echo $AVAILABLE_SYSTEM_INTEGRATIONS | jq -r '. | length')
  __process_msg "Successfully fetched enabled system integrations from db: $available_integrations_length"

}

validate_systemIntegrations() {
  __process_msg "Validating system integrations list in state.json"
  local enabled_master_integrations=$(echo $ENABLED_MASTER_INTEGRATIONS \
    | jq '.')
  local enabled_master_integrations_length=$(echo $enabled_master_integrations \
    | jq -r '. | length')

  if [ $enabled_master_integrations_length -eq 0 ]; then
    __process_msg "Misconfigured state.json. State cannot have zero master integrations, please reconfigure state " \
      " to insert master integrations"
    exit 1
  fi

  local enabled_system_integrations=$(cat $STATE_FILE \
    | jq '.systemIntegrations')
  local enabled_system_integrations_length=$(echo $enabled_system_integrations \
    | jq -r '. | length')

  if [ $enabled_system_integrations_length -eq 0 ]; then
    __process_msg "Please add system integrations and run installer again"
  fi

  for i in $(seq 1 $enabled_system_integrations_length); do
    local enabled_system_integration=$(echo $enabled_system_integrations \
      | jq '.['"$i-1"']')
    local enabled_system_integration_name=$(echo $enabled_system_integration \
      | jq -r '.name')
    local enabled_system_integration_master_name=$(echo $enabled_system_integration \
      | jq -r '.masterName')
    local enabled_system_integration_master_type=$(echo $enabled_system_integration \
      | jq -r '.masterType')
    local is_valid_system_integration=false

    for j in $(seq 1 $enabled_master_integrations_length); do
      local enabled_master_integration=$(echo $enabled_master_integrations \
        | jq '.['"$j-1"']')
      local enabled_master_integration_name=$(echo $enabled_master_integration \
        | jq -r '.name')
      local enabled_master_integration_type=$(echo $enabled_master_integration \
        | jq -r '.type')


      if [ $enabled_system_integration_master_name == $enabled_master_integration_name ] && \
        [ $enabled_system_integration_master_type == $enabled_master_integration_type ]; then
        # found associated master integration
        is_valid_system_integration=true
        break
      fi
    done

    if [ $is_valid_system_integration == false ]; then
      __process_msg "Invalid system integration in state.json: '$enabled_system_integration_name'." \
        " Cannot find releated master integration"
      __process_msg "Please add master integration for the provider or remove the system integration " \
        " and run installer again"
      exit 1
    fi

  done
  __process_msg "Successfully validated system integrations"
}

upsert_systemIntegrations() {
  local enabled_system_integrations=$(cat $STATE_FILE \
    | jq '.systemIntegrations')
  local enabled_system_integrations_length=$(echo $enabled_system_integrations \
    | jq -r '. | length')

  local available_system_integrations=$(echo $AVAILABLE_SYSTEM_INTEGRATIONS \
    | jq '.')
  local available_system_integrations_length=$(echo $available_system_integrations \
    | jq -r '. | length')

  local api_url=$(cat $STATE_FILE | jq -r '.systemSettings.apiUrl')
  local api_token=$(cat $STATE_FILE | jq -r '.systemSettings.serviceUserToken')

  for i in $(seq 1 $enabled_system_integrations_length); do
    local enabled_system_integration=$(echo $enabled_system_integrations \
      | jq '.['"$i-1"']')
    local enabled_system_integration_master_name=$(echo $enabled_system_integration \
      | jq -r '.masterName')
    local enabled_system_integration_master_type=$(echo $enabled_system_integration \
      | jq -r '.masterType')

    local is_system_integration_available=false
    local system_integration_to_update=""
    local system_integration_in_db=""

    for j in $(seq 1 $available_system_integrations_length); do
      local available_system_integration=$(echo $available_system_integrations \
        | jq '.['"$j-1"']')
      local available_system_integration_master_name=$(echo $available_system_integration \
        | jq -r '.masterName')
      local available_system_integration_master_type=$(echo $available_system_integration \
        | jq -r '.masterType')

      if [ $enabled_system_integration_master_name == $available_system_integration_master_name ] && \
        [ $enabled_system_integration_master_type == $available_system_integration_master_type ]; then
        is_system_integration_available=true
        system_integration_to_update=$enabled_system_integration
        system_integration_in_db=$available_system_integration
      fi
    done

    if [ $is_system_integration_available == true ]; then
      # put the system integration with values in state.json
      __process_msg "System integration already present, updating it: $enabled_system_integration_master_name"
      local db_system_integration_id=$(echo $system_integration_in_db \
        | jq -r '.id')
      local db_system_integration_master_name=$(echo $system_integration_in_db \
        | jq -r '.masterName')
      local db_system_integration_master_display_name=$(echo $system_integration_in_db \
        | jq -r '.masterDisplayName')

      enabled_system_integration=$(echo $enabled_system_integration \
        | jq '.id="'$db_system_integration_id'"')
      enabled_system_integration=$(echo $enabled_system_integration \
        | jq '.masterName="'$db_system_integration_master_name'"')
      enabled_system_integration=$(echo $enabled_system_integration \
        | jq '.masterDisplayName="'$db_system_integration_master_display_name'"')

      local integrations_put_endpoint="$api_url/systemIntegrations/$db_system_integration_id"
      local post_call_resp_code=$(curl \
        -H "Content-Type: application/json" \
        -H "Authorization: apiToken $api_token" \
        -X PUT \
        -d "$enabled_system_integration" \
        $integrations_put_endpoint \
        --write-out "%{http_code}\n" \
        --silent \
        --output /dev/null)
      if [ "$post_call_resp_code" -gt "299" ]; then
        echo "Error adding integration for $enabled_system_integration_master_name(status code $post_call_resp_code)"
      else
        echo "Sucessfully added integration for $enabled_system_integration_master_name"
      fi

    else
      # find the master integration for this system integration
      # post a new system integration
      __process_msg "Adding new system integration: $enabled_system_integration_master_name"
      local enabled_master_integration=$(echo $ENABLED_MASTER_INTEGRATIONS \
        | jq '.[] | 
          select
            (.name == "'$enabled_system_integration_master_name'"
            and .type == "'$enabled_system_integration_master_type'")')
      local enabled_master_integration_id=$(echo $enabled_master_integration \
        | jq -r '.id')
      local enabled_master_integration_display_name=$(echo $enabled_master_integration \
        | jq -r '.displayName')
      local enabled_master_integration_name=$(echo $enabled_master_integration \
        | jq -r '.name')

      enabled_system_integration=$(echo $enabled_system_integration \
        | jq '.masterIntegrationId="'$enabled_master_integration_id'"')
      enabled_system_integration=$(echo $enabled_system_integration \
        | jq '.masterDisplayName="'$enabled_master_integration_display_name'"')
      enabled_system_integration=$(echo $enabled_system_integration \
        | jq '.masterName="'$enabled_master_integration_name'"')
      enabled_system_integration=$(echo $enabled_system_integration \
        | jq '.isEnabled=true')

      local=$(echo $enabled_provider \
        | jq '.masterIntegrationId="'$enabled_master_integration_id'"')

      local integrations_post_endpoint="$api_url/systemIntegrations"
      local post_call_resp_code=$(curl \
        -H "Content-Type: application/json" \
        -H "Authorization: apiToken $api_token" \
        -X POST \
        -d "$enabled_system_integration" \
        $integrations_post_endpoint \
        --write-out "%{http_code}\n" \
        --silent \
        --output /dev/null)
      if [ "$post_call_resp_code" -gt "299" ]; then
        echo "Error adding integration for $enabled_master_integration_display_name(status code $post_call_resp_code)"
      else
        echo "Sucessfully added integration for $enabled_master_integration_display_name"
      fi

    fi
  done
}

delete_systemIntegrations() {
  # for each SI in list
  # if there is no MI, ask user to delete SI from list
  #   and try again

  # get all systemIntegrations from db
  # if systemIntegrations not in state, DELETE from db 

  true
}

main() {
  __process_marker "Configuring system integrations"
  get_enabled_masterIntegrations
  get_enabled_systemIntegrations
  validate_systemIntegrations
  upsert_systemIntegrations
  delete_systemIntegrations
}

main
