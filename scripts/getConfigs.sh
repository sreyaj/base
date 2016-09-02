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
  __process_msg "Fetched config from s3 and wrote it to config.json"
}

validate_config() {
  #TODO: validate if the config has all the fields
  # like  version, customer id, license key, integrations etc
  __process_msg "Validating config"
}

bootstrap_state() {
  __process_msg "Bootstrapping state.json"

  local release=$(cat $CONFIG_FILE | jq -r '.release')
  local bootstrap_state=$(jq -n --arg v "$initial_obj" \
    '{
      "release": "'$release'",
      "systemSettings": {},
      "services": [],
      "machines": []
    }' \
  | tee $STATE_FILE)


  local service_count=$(cat $CONFIG_FILE | jq '.services | length')
  local service_list=$(cat $CONFIG_FILE | jq '.services')
  
  for i in $(seq 1 $service_count); do
    local service_name=$(echo $service_list | jq '.['"$i-1"'] | .name')
    local services_state=$(cat $STATE_FILE | jq '
      .services |= . + [{
        "name": '"$service_name"'
      }]
    ')
    _update_state "$services_state"
  done

  local domain=$(cat $CONFIG_FILE | \
    jq -r '.systemSettings.domain')
  local domain_update=$(cat $STATE_FILE | \
    jq '.systemSettings.domain="'$domain'"')
  _update_state "$domain_update"

  local domain_protocol=$(cat $CONFIG_FILE | jq -r '.systemSettings.domainProtocol')
  local domain_protocol_update=$(cat $STATE_FILE | \
    jq '.systemSettings.domainProtocol="'$domain_protocol'"')
  _update_state "$domain_protocol_update"
}

main() {
  __process_marker "Getting config"
  get_system_config
  validate_config
  bootstrap_state
}

main
