#!/bin/baseh -e

export AVAILABLE_PROVIDERS=""
export ENABLED_MASTER_INTEGRATIONS=""

get_available_masterIntegrations() {
  __process_msg "GET-ing enabled master integrations from db"
  # GET MI list from DB update global variable
  # that are isEnabled=true
  true
}

validate_providers() {
  __process_msg "Validating providers list in state.json"
  # for each MI in list
  # if there is no provider in provider list, errro
  # else, provider list is valid
  true
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
  get_available_masterIntegrations
  validate_providers
  upsert_providers
  delete_providers
}

main
