#!/bin/baseh -e

export AVAILABLE_PROVIDERS=""
export ENABLED_MASTER_INTEGRATIONS=""

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

    ENABLED_MASTER_INTEGRATIONS=$(echo $response | jq '[ .[] | select(.isEnabled==true) ]')
    local enabled_integrations_length=$(echo $ENABLED_MASTER_INTEGRATIONS | jq -r '. | length')
    __process_msg "Successfully fetched master integration list: $enabled_integrations_length"
  else
    local error=$(echo $response | jq '.')
    __process_msg "Error GET-ing master integration list: $error"
  fi
}

get_providers() {
  __process_msg "GET-ing available providers from db"
  local api_token=$(cat $STATE_FILE | jq -r '.systemSettings.serviceUserToken')
  local api_url=$(cat $STATE_FILE | jq -r '.systemSettings.apiUrl')
  local master_integrations_get_endpoint="$api_url/providers"

  local response=$(curl \
    -H "Content-Type: application/json" \
    -H "Authorization: apiToken $api_token" \
    -X GET $master_integrations_get_endpoint \
    --silent)
  response=$(echo $response | jq '.')

  AVAILABLE_PROVIDERS=$(echo $response | jq '.')
  local available_providers_length=$(echo $AVAILABLE_PROVIDERS | jq -r '. | length')
  __process_msg "Successfully fetched providers from db: $available_providers_length"
}

validate_providers() {
  __process_msg "Validating providers list in state.json"
  local enabled_master_integrations=$(echo $ENABLED_MASTER_INTEGRATIONS \
    | jq '.')
  local enabled_master_integrations_length=$(echo $enabled_master_integrations \
    | jq -r '. | length')

  if [ $enabled_master_integrations_length -eq 0 ]; then
    __process_msg "Misconfigured state.json. State cannot have zero master integrations, please reconfigure state " \
      " to insert master integrations"
    exit 1
  fi

  local enabled_providers=$(cat $STATE_FILE | jq '.masterIntegrationProviders')
  local enabled_providers_length=$(echo $enabled_providers | jq '. | length')

  # make sure each provider has an integration, else ask to remove it
  # NOTE: an interation might or might not have a provider but a provider
  # HAS to be associated with an integration
  for i in $(seq 1 $enabled_providers_length); do
    local enabled_provider=$(echo $enabled_providers \
      | jq '.['"$i-1"']')
    local enabled_provider_name=$(echo $enabled_provider \
      | jq -r '.name')
    local enabled_provider_type=$(echo $enabled_provider \
      | jq -r '.type')
    local is_valid_master_integration_provider=false

    for j in $(seq 1 $enabled_master_integrations_length); do
      local enabled_master_integration=$(echo $enabled_master_integrations \
        | jq '.['"$j-1"']')
      local enabled_master_integration_name=$(echo $enabled_master_integration \
        | jq -r '.name')
      local enabled_master_integration_type=$(echo $enabled_master_integration \
        | jq -r '.type')

      if [ $enabled_master_integration_name == $enabled_provider_name ] && \
        [ $enabled_master_integration_type == $enabled_provider_type ]; then
        is_valid_master_integration_provider=true
        break
      fi
    done

    if [ $is_valid_master_integration_provider == false ]; then
      __process_msg "Invalid master integration provider in state.json: '$enabled_provider'" \
        "of type '$enabed_provider_type'. Cannot find releated master integration"
      __process_msg "Please add integration for the provider or remove the provider and run installer again"
      exit 1
    fi

  done

  __process_msg "Providers  list in state.json valid, proceeding"
}

upsert_providers() {
  __process_msg "upserting providers in db"

  local enabled_master_integrations=$(echo $ENABLED_MASTER_INTEGRATIONS \
    | jq '.')
  local enabled_master_integrations_length=$(echo $enabled_master_integrations \
    | jq -r '. | length')
  local enabled_providers=$(cat $STATE_FILE | jq '.masterIntegrationProviders')
  local enabled_providers_length=$(echo $enabled_providers | jq '. | length')

  local api_url=$(cat $STATE_FILE | jq -r '.systemSettings.apiUrl')
  local api_token=$(cat $STATE_FILE | jq -r '.systemSettings.serviceUserToken')

  # for each provider in the statefile
  # find MI from the list
  for i in $(seq 1 $enabled_providers_length); do
    local enabled_provider=$(echo $enabled_providers \
      | jq '.['"$i-1"']')
    local enabled_provider_name=$(echo $enabled_provider \
      | jq -r '.name')
    local enabled_provider_type=$(echo $enabled_provider \
      | jq -r '.type')

    for j in $(seq 1 $enabled_master_integrations_length); do
      local enabled_master_integration=$(echo $enabled_master_integrations \
        | jq '.['"$j-1"']')
      local enabled_master_integration_name=$(echo $enabled_master_integration \
        | jq -r '.name')
      local enabled_master_integration_type=$(echo $enabled_master_integration \
        | jq -r '.type')
      local enabled_master_integration_id=$(echo $enabled_master_integration \
        | jq -r '.id')

      if [ $enabled_master_integration_name == $enabled_provider_name ] && \
        [ $enabled_master_integration_type == $enabled_provider_type ]; then
        
        # found the integration for the provider

        # find provider from db
        local db_master_integration_provider=$(echo $AVAILABLE_PROVIDERS \
          | jq -r '.[] |
            select(
            .name=="'$enabled_master_integration_name'" 
            and 
            .masterIntegrationId=="'$enabled_master_integration_id'")')

        if [ -z "$db_master_integration_provider" ]; then
          __process_msg "no provider exists in DB for master integration: $enabled_master_integration_name, inserting"
          local master_integration_provider=$(echo $enabled_provider \
            | jq '.masterIntegrationId="'$enabled_master_integration_id'"')

          echo "----------"
          echo $master_integration_provider

          local providers_post_endpoint="$api_url/providers"
          local post_call_resp_code=$(curl \
            -H "Content-Type: application/json" \
            -H "Authorization: apiToken $api_token" \
            -X POST \
            -d "$master_integration_provider" \
            $providers_post_endpoint \
            --write-out "%{http_code}\n" \
            --silent \
            --output /dev/null)
          if [ "$post_call_resp_code" -gt "299" ]; then
            echo "Error adding provider for $enabled_master_integration_name(status code $post_call_resp_code)"
          else
            echo "Sucessfully added provider for $enabled_master_integration_name"
          fi

        else
          __process_msg "provider already exists in DB for master integration: $enabled_master_integration_name, updating"
          local db_master_integration_provider_id=$(echo $db_master_integration_provider | jq -r '.id')
          local providers_put_endpoint="$api_url/providers/$db_master_integration_provider_id"
          local put_call_resp_code=$(curl \
            -H "Content-Type: application/json" \
            -H "Authorization: apiToken $api_token" \
            -X PUT \
            -d "$db_master_integration_provider" \
            $providers_put_endpoint \
            --write-out "%{http_code}\n" \
            --silent \
            --output /dev/null)
          if [ "$put_call_resp_code" -gt "299" ]; then
            echo "Error updating provider for $enabled_master_integration_name(status code $put_call_resp_code)"
          else
            echo "Sucessfully updated provider for $enabled_master_integration_name"
          fi

        fi
    
      fi

    done

  done
}

delete_providers() {
  __process_msg "deleting redudant providers"
  # for each provider in list
  # if there is no MI, ask user to remove the provider from list
  #   and try again

  # GET all providers from db
  # if providers not in state, DELETE providers from db
}

main() {
  __process_marker "Configuring providers"
  get_enabled_masterIntegrations
  get_providers
  validate_providers
  upsert_providers
  #delete_providers
}

main
