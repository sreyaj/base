#!/bin/bash -e

export AVAILABLE_MASTER_INTEGRATIONS=""
export ENABLED_MASTER_INTEGRATIONS=""
export DISABLED_MASTER_INTEGRATIONS=""

get_available_masterIntegrations() {
  __process_msg "GET-ing available master integrations from db"
  # GET MI list from DB update global variable
  true
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
