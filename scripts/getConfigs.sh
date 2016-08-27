#!/bin/bash -e

readonly SERVICES_CONFIG="$DATA_DIR/config.json"

###########################################################
#s3 access
readonly CONFIG_ACCESS_KEY="test"
#s3 secret
readonly CONFIG_SECRET_KEY="test"
#s3 bucket
readonly CONFIG_FOLDER="test"


get_system_config() {
  #TODO: curl into s3 using the keys to get the config
  echo "Fetched config from s3 and wrote it to config.json"
}

validate_config() {
  #TODO: validate if the config has all the fields
  # like  version, customer id, license key, integrations etc
  echo "validating config"
}

main() {
  echo "starting installation"

  get_system_config
  validate_config
}

main
