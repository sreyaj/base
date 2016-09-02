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
  if [ -z "$RELEASE" ]; then
    echo "Cannot find release version, exiting..."
    exit 1
  else
    __process_msg "Installing Shippable release : $RELEASE"
  fi

  if [ ! -f "$DATA_DIR/config.json" ]; then
    echo "Cannot find config.json, exiting..."
    exit 1
  else
    __process_msg "Found config.json"
  fi

  if [ ! -f "$DATA_DIR/machines.json" ]; then
    echo "Cannot find machines.json, exiting..."
    exit 1
  else
    __process_msg "Found machines.json"
  fi

  if [ ! -f "$DATA_DIR/core.json" ]; then
    echo "Cannot find core.json, exiting..."
    exit 1
  else
    __process_msg "Found core.json"
  fi

  if [ ! -f "$DATA_DIR/state.json" ]; then
    __process_msg "No state.json exists, creating..."
    touch "$STATE_FILE"
  else
    __process_msg "state.json exists"
  fi

  local customer_id=$(cat $CONFIG_FILE | jq '.shippableCustomerId')
  if [ -z "$customer_id" ]; then
    echo "Cannot find customer id in config.json, exiting..."
    exit 1
  fi

  local license_key=$(cat $CONFIG_FILE | jq '.licenseKey')
  if [ -z "$license_key" ]; then
    echo "Cannot find customer id in config.json, exiting..."
    exit 1
  fi
}

bootstrap_state() {
  __process_msg "Bootstrapping state.json"

  local release=$(cat $CONFIG_FILE | jq -r '.release')
  local bootstrap_state=$(jq -n --arg v "$initial_obj" \
    '{
      "release": "'$release'",
      "systemSettings": {},
      "services": [],
      "machines": [],
      "systemIntegrations": [],
      "core": [],
      "inProgress": "true"
    }' \
  | tee $STATE_FILE)
  __process_msg "Created state.json template"

  local service_count=$(cat $CONFIG_FILE | jq '.services | length')
  local service_list=$(cat $CONFIG_FILE | jq '.services')
  
  for i in $(seq 1 $service_count); do
    local service_name=$(echo $service_list | jq '.['"$i-1"'] | .name')
    local services_state=$(cat $STATE_FILE | jq '
      .services |= . + [{
        "name": '"$service_name"',
        "isRunning": "false"
      }]
    ')
    _update_state "$services_state"
  done
  __process_msg "Updated services in state.json"

  local domain=$(cat $CONFIG_FILE | \
    jq -r '.systemSettings.domain')
  local domain_update=$(cat $STATE_FILE | \
    jq '.systemSettings.domain="'$domain'"')
  _update_state "$domain_update"

  __process_msg "Updated domain in state.json"

  local domain_protocol=$(cat $CONFIG_FILE | jq -r '.systemSettings.domainProtocol')
  local domain_protocol_update=$(cat $STATE_FILE | \
    jq '.systemSettings.domainProtocol="'$domain_protocol'"')
  _update_state "$domain_protocol_update"

  __process_msg "Updated domain protocol in state.json"
}

main() {
  __process_marker "Getting config"
  get_system_config
  validate_config
  bootstrap_state
}

main
