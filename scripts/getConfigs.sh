#!/bin/bash -e

###########################################################
validate_version() {
  __process_msg "validating version"
  if [ ! -f "$DATA_DIR/machines.json" ]; then
    echo "Cannot find machines.json, exiting..."
    exit 1
  else
    __process_msg "Found machines.json"
  fi

  #TODO check versions directory, error if empty
  #TODO check migrations directory, error if empty
}

generate_state() {
  if [ ! -f "$DATA_DIR/state.json" ]; then
    if [ -f "$DATA_DIR/state.json.backup" ]; then
      __process_msg "A state.json.backup file exists, do you want to use the backup? (yes/no)"
      read response
      if [[ "$response" == "yes" ]]; then
        cp -vr $DATA_DIR/state.json.backup $DATA_DIR/state.json
        rm $DATA_DIR/state.json.backup || true
      else
        __process_msg "Dicarding backup, creating a new state.json from state.json.example"
        cp -vr $DATA_DIR/state.json.example $DATA_DIR/state.json
        rm $DATA_DIR/state.json.backup || true
      fi
    else
      __process_msg "No state.json exists, creating a new state.json from state.json.example."
      cp -vr $DATA_DIR/state.json.example $DATA_DIR/state.json
      rm $DATA_DIR/state.json.backup || true
    fi
  else
    __process_msg "using existing state.json"
  fi
}

bootstrap_state() {
  local release_version=$(cat $STATE_FILE | jq -r '.release')
  if [ -z "$release_version" ]; then
    __process_msg "bootstrapping state.json for latest release"

    ##TODO parse this from versions file
    __process_msg "updating release version"
    release_version="v4.10.28"
    local release=$(cat $STATE_FILE | jq '.release="'"$release_version"'"')
    update=$(echo $release | jq '.' | tee $STATE_FILE)

    __process_msg "injecting empty machines array"
    local machines=$(cat $STATE_FILE | \
      jq '.machines=[]')
    update=$(echo $machines | jq '.' | tee $STATE_FILE)

    __process_msg "injecting empty master integrations"
    local master_integrations=$(cat $STATE_FILE | \
      jq '.masterIntegrations=[]')
    update=$(echo $master_integrations | jq '.' | tee $STATE_FILE)

    __process_msg "injecting empty providers"
    local providers=$(cat $STATE_FILE | \
      jq '.masterIntegrationProviders=[]')
    update=$(echo $providers | jq '.' | tee $STATE_FILE)

    __process_msg "injecting empty system integrations"
    local system_integrations=$(cat $STATE_FILE | \
      jq '.systemIntegrations=[]')
    update=$(echo $system_integrations | jq '.' | tee $STATE_FILE)

    __process_msg "injecting empty services array"
    local services=$(cat $STATE_FILE | \
      jq '.services=[]')
    update=$(echo $services | jq '.' | tee $STATE_FILE)

    __process_msg "state.json bootstrapped with default values"
  else
    __process_msg "using existing state.json for version $release_version"
  fi
}

validate_state() {
  __process_msg "validating state.json"
  # parse from jq
  local release_version=$(cat $STATE_FILE | jq -r '.release')
  # check if version exists
  # check if installer array exists
  # check if systemconfig object exists
  # check if masterIntegration exist
  # check if providers exit
  # check if systemIntegrations exist
  # check if systemImages exist
  # check if systemMachineImages exist
  # check if services exist
  __process_msg "state.json valid, proceeding with installation"
}

bootstrap_state_old() {
  __process_msg "Bootstrapping state.json"
   local bootstrap_state=$(jq -n --arg v "$initial_obj" \
      '{
        "release": "'$release_version'",
        "masterIntegrations": [],
        "masterIntegrationProviders": [],
        "systemIntegrations": [],
        "services": [],
        "machines": [],
        "inProgress": "true",
      }' \
    | tee $STATE_FILE)

 local release=$(cat $CONFIG_FILE | jq -r '.release')
 local bootstrap_state=$(jq -n --arg v "$initial_obj" \
    '{
      "release": "'$release'",
      "systemSettings": {},
      "services": [
        {
          "name": "api"
        }
      ],
      "machines": [],
      "systemIntegrations": [],
      "core": [],
      "inProgress": "true",
      "installStatus": {}
    }' \
  | tee $STATE_FILE)
  __process_msg "Created state.json template"

  local service_count=$(cat $CONFIG_FILE | jq '.services | length')
  local service_list=$(cat $CONFIG_FILE | jq '.services')

  for i in $(seq 1 $service_count); do
    local service_name=$(echo $service_list | jq '.['"$i-1"'] | .name')
    local service_image=$(echo $service_list | jq '.['"$i-1"'] | .image')
    local services_state=$(cat $STATE_FILE | jq '
      .services |= . + [{
        "name": '"$service_name"',
        "image": '"$service_image"',
        "isRunning": "false"
      }]
    ')
    _update_state "$services_state"
  done
  __process_msg "Updated services in state.json"
}

main() {
  __process_marker "Configuring installer"
  validate_version
  generate_state
  bootstrap_state
  validate_state
}

main
