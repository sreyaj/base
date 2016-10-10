#!/bin/bash -e

export ENABLED_MASTER_INTEGRATIONS=""
export AVAILABLE_SYSTEM_INTEGRATIONS=""

get_available_masterIntegrations() {
  # GET MI list from DB update global variable
  # that are isEnabled=true and type="system"
  true
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
  get_available_masterIntegrations
  validate_systemIntegrations
  upsert_systemIntegrations
  delete_systemIntegrations
}

main
