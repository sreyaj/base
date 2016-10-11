#!/bin/bash -e

export ENABLED_MASTER_INTEGRATIONS=""
export AVAILABLE_SYSTEM_INTEGRATIONS=""

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
  __process_msg "Successfully fetched providers from db: $available_integrations_length"

}

validate_systemIntegrations() {
  # for each MI in list
  # if there is no systemintegration, error
  # else, valid list
  true
}

upsert_systemIntegrations() {
  # for each MI in list
  # find systemintegration from statefile
  # get systemINtegration from db
  # if 404, POST systemIntegration
  # if 200, PUT systemIntegration
  true
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
