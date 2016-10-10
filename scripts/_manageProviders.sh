#!/bin/baseh -e

export AVAILABLE_PROVIDERS=""
export ENABLED_MASTER_INTEGRATIONS=""

get_enabled_masterIntegrations() {
  __process_msg "GET-ing available master integrations from db"
  # GET MI list from DB update global variable
  # that are isEnabled=true
  # TODO: after GET route is fixed, use filters only

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

    local service_machines_list=$(cat $STATE_FILE | jq '[ .machines[] | select(.group=="services") ]')

    ENABLED_MASTER_INTEGRATIONS=$(echo $response | jq '[ .[] | select(.isEnabled==true) ]')
  else
    local error=$(echo $response | jq '.')
    __process_msg "Error GET-ing master integration list: $error"
  fi
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

  ## make sure each integration has a provider
  local enabled_providers=$(cat $STATE_FILE | jq '.masterIntegrationProviders')
  local enabled_providers_length=$(echo $enabled_providers | jq '. | length')

  for i in $(seq 1 $enabled_master_integrations_length); do
    local enabled_master_integration=$(echo $enabled_master_integrations \
      | jq '.['"$i-1"']')
    local enabled_master_integration_name=$(echo $enabled_master_integration \
      | jq -r '.name')
    local enabled_master_integration_type=$(echo $enabled_master_integration \
      | jq -r '.type')
    local is_valid_master_integration=false

    for j in $(seq 1 $enabled_providers_length); do
      local enabled_provider=$(echo $enabled_providers \
        | jq '.['"$j-1"']')
      local enabled_provider_name=$(echo $enabled_provider \
        | jq -r '.name')
      local enabled_provider_type=$(echo $enabled_provider \
        | jq -r '.type')

      if [ $enabled_master_integration_name == $enabled_provider_name ] && \
        [ $enabled_master_integration_type == $enabled_provider_type ]; then
        is_valid_master_integration=true
        break
      fi
    done

    if [ $is_valid_master_integration == false ]; then
      __process_msg "Invalid master integration in state.json: '$enabled_master_integration_name'" \
        "of type '$enabled_master_integration_type'. Cannot find integration provider"
      __process_msg "Please add integration provider and run installer again"
      exit 1
    fi
  done

  # make sure each provider has an integration, else ask to remove it
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
  # for each MI in list
  # find the provider from statefile
  # GET the provider from db
  # if 404, POST provider
  # if 200, PUT provider
  true
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
  validate_providers
  upsert_providers
  delete_providers
}

main
