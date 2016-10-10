#!/bin/bash -e

export AVAILABLE_MASTER_INTEGRATIONS=""
export ENABLED_MASTER_INTEGRATIONS=""
export DISABLED_MASTER_INTEGRATIONS=""

get_available_masterIntegrations() {
  __process_msg "GET-ing available master integrations from db"
  # GET MI list from DB update global variable

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
  else
    local error=$(echo $response | jq '.')
    __process_msg "Error GET-ing master integration list: $error"
  fi
}

validate_masterIntegrations(){
  __process_msg "Validating master integrations in state.json"
  # get MI from statefile,
  # if no integrations, show list and exit
  # if any is not in db list, show error and exit
  # else all in state are in db, list is valid
  # update the enabled list with the ones in state
  true
}

enable_masterIntegrations() {
  __process_msg "enabling master integrations in db"
  # for all integrations in enabled list, PUT on db with enabled=true
  true
}

disable_masterIntegrations() {
  __process_msg "disabling redundant master integrations"
  # for all integrations in available list,
  # if the integration is not in enabled list,
  # PUT on db with enabled=false
  true
}

main() {
  __process_marker "Configuring master integrations"
  get_available_masterIntegrations
  validate_masterIntegrations
  enable_masterIntegrations
  disable_masterIntegrations
}

main
