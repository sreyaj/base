#!/bin/bash -e

add_master_integrations() {
  # TODO: add master integrations into database
  echo "add master integrations into database"
}

add_system_integrations() {
  #TODO: add system integrations into vault
  # the namespace will be in the format
  # /system/<name>/<master integration>/key-values
  # api will read them later and insert them into database
  echo "add system integrations into vault"
}

update_system_config() {
  #TODO: read systemConfig from data/config.json
  # update systemConfig values for
  # serviceUserToken
  # vault URL
  # vault root token
  echo "updating systemConfig"
}

main() {
  add_master_integrations
  add_system_integrations
  update_system_config
}

main
