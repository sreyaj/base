#!/bin/bash -e

export AVAILABLE_MASTER_INTEGRATIONS=""
export ENABLED_MASTER_INTEGRATIONS=""
export DISABLED_MASTER_INTEGRATIONS=""

get_available_masterIntegrations() {
  __process_msg "GET-ing available master integrations from db"

  local api_url=""
  local api_token=$(cat $STATE_FILE | jq -r '.systemSettings.serviceUserToken')
  local api_url=$(cat $STATE_FILE | jq -r '.systemSettings.apiUrl')
  local master_integrations_get_endpoint="$api_url/masterIntegrations"

  local response=$(curl -H "Content-Type: application/json" -H "Authorization: apiToken $api_token" \
    -X GET $master_integrations_get_endpoint \
    --silent)
  response=$(echo $response | jq '.')
  local response_length=$(echo $response | jq '. | length')

  if [ $response_length -gt 5 ]; then
    ## NOTE: we're assuming we have at least 5 master integrations in global list
    __process_msg "Successfully fetched master integration list: $response_length"
    AVAILABLE_MASTER_INTEGRATIONS=$(echo $response | jq '.')
  else
    local error=$(echo $response | jq '.')
    __process_msg "Error GET-ing master integration list: $error"
  fi
}

validate_masterIntegrations(){
  __process_msg "Validating master integrations in state.json"

  local enabled_master_integrations=$(cat $STATE_FILE | jq '.masterIntegrations')
  local enabled_master_integrations_length=$(echo $enabled_master_integrations \
    | jq -r '. | length')
  local available_master_integrations_length=$(echo $AVAILABLE_MASTER_INTEGRATIONS \
    | jq -r '. | length')

  if [ $enabled_master_integrations_length -eq 0 ]; then
    __process_msg "Please enable 'masterIntegrations' in state.json and run installer again"
    __process_msg "List of available 'masterIntegrations'"

    printf "\n\t%25s %10s\n" "Master Integration Name" "Type"
    printf "%s----------------------------------------------\n"
    for i in $(seq 1 $available_master_integrations_length); do
      local master_integration=$(echo $AVAILABLE_MASTER_INTEGRATIONS \
        | jq '.['"$i-1"']')

      local master_integration_name=$(echo $master_integration | jq -r '.name')
      local master_integration_type=$(echo $master_integration | jq -r '.type')
      printf "\t%25s %10s\n" $master_integration_name $master_integration_type
    done

    exit 1
  fi

  ## some integration available in sate file,
  ## validate against database
  for i in $(seq 1 $enabled_master_integrations_length); do
    local enabled_master_integration=$(echo $enabled_master_integrations \
      | jq '.['"$i-1"']')
    local enabled_master_integration_name=$(echo $enabled_master_integration \
      | jq -r '.name')
    local enabled_master_integration_type=$(echo $enabled_master_integration \
      | jq -r '.type')
    local is_valid_master_integration=false

    for j in $(seq 1 $available_master_integrations_length); do
      local available_master_integration=$(echo $AVAILABLE_MASTER_INTEGRATIONS \
        | jq '.['"$j-1"']')
      local available_master_integration_name=$(echo $available_master_integration \
        | jq -r '.name')
      local available_master_integration_type=$(echo $available_master_integration \
        | jq -r '.type')


      if [ "$enabled_master_integration_name" == "$available_master_integration_name"  ] && \
        [ "$enabled_master_integration_type" == "$available_master_integration_type" ]; then
        is_valid_master_integration=true
        break
      fi
    done

    if [ $is_valid_master_integration == false ]; then
      __process_msg "Invalid master integration in state.json: '$enabled_master_integration_name'" \
        "of type '$enabled_master_integration_type'"
    fi

  done

  __process_msg "Master integration list in state.json valid, proceeding"
}

enable_masterIntegrations() {
  __process_msg "enabling master integrations in db"
  local enabled_master_integrations=$(cat $STATE_FILE | jq '.masterIntegrations')
  local enabled_master_integrations_length=$(echo $enabled_master_integrations \
    | jq -r '. | length')
  local available_master_integrations_length=$(echo $AVAILABLE_MASTER_INTEGRATIONS \
    | jq -r '. | length')

  local api_token=$(cat $STATE_FILE | jq -r '.systemSettings.serviceUserToken')
  local api_url=$(cat $STATE_FILE | jq -r '.systemSettings.apiUrl')

  for i in $(seq 1 $enabled_master_integrations_length); do
    local enabled_master_integration=$(echo $enabled_master_integrations \
      | jq '.['"$i-1"']')
    local enabled_master_integration_name=$(echo $enabled_master_integration \
      | jq -r '.name')
    local enabled_master_integration_type=$(echo $enabled_master_integration \
      | jq -r '.type')

    for j in $(seq 1 $available_master_integrations_length); do
      local available_master_integration=$(echo $AVAILABLE_MASTER_INTEGRATIONS \
        | jq '.['"$j-1"']')
      local available_master_integration_id=$(echo $available_master_integration \
        | jq -r '.id')
      local available_master_integration_name=$(echo $available_master_integration \
        | jq -r '.name')
      local available_master_integration_type=$(echo $available_master_integration \
        | jq -r '.type')


      if [ "$enabled_master_integration_name" == "$available_master_integration_name"  ] && \
        [ "$enabled_master_integration_type" == "$available_master_integration_type" ]; then
        is_valid_master_integration=true
        updated_master_integration=$(echo $available_master_integration | jq '.isEnabled=true')

        local master_integration_put_endpoint="$api_url/masterIntegrations/$available_master_integration_id"
        local put_call_resp_code=$(curl -H "Content-Type: application/json" -H "Authorization: apiToken $api_token" \
          -X POST -d "$updated_master_integration" $master_integration_put_endpoint \
            --write-out "%{http_code}\n" --silent --output /dev/null)
        if [ "$put_call_resp_code" -gt "299" ]; then
          echo "Error enabling master integration $available_master_integration_name(status code $put_call_resp_code)"
        else
          echo "Sucessfully enabled master integration $available_master_integration_name"
        fi

        break
      fi
    done
  done
}

disable_masterIntegrations() {
  # for all integrations in db enabled list,
  # if the integration is not in state enabled list,
  # PUT on db with enabled=false
  __process_msg "disabling redundant master integrations"
  local db_enabled_master_integrations=$(echo $AVAILABLE_MASTER_INTEGRATIONS | jq '[ .[] | select (.isEnabled==true) ]')
  local db_enabled_master_integrations_length=$(echo $db_enabled_master_integrations \
    | jq -r '. | length')

  local enabled_master_integrations=$(echo $STATE_FILE \
    | jq -r '.masterIntegrations')
  local enabled_master_integrations_length=$(echo $enabled_master_integrations \
    | jq -r '. | length')

  for i in $(seq 1 $db_enabled_master_integrations_length); do
    local db_enabled_master_integration=$(echo $db_enabled_master_integrations \
      | jq '.['"$i-1"']')
    local db_enabled_master_integration_name=$(echo $db_enabled_master_integration \
      | jq -r '.name')
    local db_enabled_master_integration_type=$(echo $db_enabled_master_integration \
      | jq -r '.type')
    local db_enabled_master_integration_id=$(echo $db_enabled_master_integration \
      | jq -r '.id')
    local is_valid_db_master_integration=false

    for j in $(seq 1 $enabled_master_integrations_length); do
      local enabled_master_integration=$(echo $enabled_master_integrations \
        | jq '.['"$j-1"']')
      local enabled_master_integration_name=$(echo $enabled_master_integration \
        | jq -r '.name')
      local enabled_master_integration_type=$(echo $enabled_master_integration \
        | jq -r '.type')


      if [ "$db_enabled_master_integration_name" == "$enabled_master_integration_name"  ] && \
        [ "$db_enabled_master_integration_type" == "$enabled_master_integration_type" ]; then
        is_valid_db_master_integration=true
        break
      fi
    done

    if [ "$is_valid_db_master_integration" == false ]; then
      local updated_master_integration=$(echo $available_master_integration | jq '.isEnabled=false')

      local master_integration_put_endpoint="$api_url/masterIntegrations/$db_enabled_master_integration_id"
      local put_call_resp_code=$(curl -H "Content-Type: application/json" -H "Authorization: apiToken $api_token" \
        -X POST -d "$updated_master_integration" $master_integration_put_endpoint \
          --write-out "%{http_code}\n" --silent --output /dev/null)
      if [ "$put_call_resp_code" -gt "299" ]; then
        echo "Error disabling integration $available_master_integration_name(status code $put_call_resp_code)"
      else
        echo "Sucessfully disabled master integration $db_enabled_master_integration_name"
      fi
    fi

  done
}

main() {
  __process_marker "Configuring master integrations"
  get_available_masterIntegrations
  validate_masterIntegrations
  #enable_masterIntegrations
  #disable_masterIntegrations
}

main
