#!/bin/bash -e

readonly SERVICES_CONFIG="$DATA_DIR/config.json"
local STATE_FILE_BACKUP="$DATA_DIR/state.json.backup"

###########################################################
#s3 access
readonly CONFIG_ACCESS_KEY="test"
#s3 secret
readonly CONFIG_SECRET_KEY="test"
#s3 bucket
readonly CONFIG_FOLDER="test"

export PROVIDER_ID=3


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

check_state_backup_exists() {
  export INIT_STATE_FILE=1
  if [ -f "$STATE_FILE_BACKUP" ]; then
    __process_msg "A state.json.backup file exists, do you want to use the backup to initialize state.json? (y/n)"
    read response
    if [[ "$response" =~ "y" ]]; then
      INIT_STATE_FILE=0
    fi
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

  __process_msg "Updated domain protocol in state.json"
}


update_system_settings() {
  __process_msg "Updating system settings in state.json from config.json"
  local system_settings=$(cat $CONFIG_FILE | jq '.systemSettings')
  local update=$(cat $STATE_FILE | jq '.systemSettings='"$system_settings"'')
  _update_state "$update"
  __process_msg "Succcessfully updated state.json with systemSettings"
}

update_install_status() {
  __process_msg "Updating install status in state.json from config.json"
  local install_status=$(cat $CONFIG_FILE | jq '.installStatus')
  local update=$(cat $STATE_FILE | jq '.installStatus='"$install_status"'')
  _update_state "$update"
  __process_msg "Succcessfully updated state.json with installStatus"
}

update_providers() {
  __process_msg "Updating providers in state.json from config.json"
  local providers_length_config=$(cat $CONFIG_FILE | jq '.providers | length')
  local providers_length_state=$(cat $STATE_FILE | jq '.providers | length')

  for i in $(seq 1 $providers_length_config); do
    local provider=$(cat $CONFIG_FILE | jq '.providers['"$i-1"']')
    local update=$(cat $STATE_FILE | jq '.providers['"$providers_length_state + $i -1"']='"$provider"'')
    update=$(echo $update | jq '.' | tee $STATE_FILE)
  done
  __process_msg "Succcessfully updated state.json with providers"
}

update_bbserver_details() {
  __process_msg "Do you want to add the BitBucket Server integration? (y/n)"
  read response
  if [[ "$response" =~ "y" ]]; then
    __process_msg "Please enter the URL for the BitBucket Server : "
    read response
    local id=$(cat /proc/sys/kernel/random/uuid)
    local url=$response
    local providers_state=$(cat $STATE_FILE | jq '
      .providers |= . + [{
        "id": "'$id'",
        "url": "'$url'",
        "providerId": '$PROVIDER_ID',
        "masterIntegrationId": "572af430ead9631100f7f64d",
        "name": "bitbucketServer",
        "createdAt": "2016-09-12T07:16:55.387Z",
        "updatedAt": "2016-09-12T08:04:18.893Z"
      }]'
    )
    echo $providers_state | jq '.' > $STATE_FILE

    ((PROVIDER_ID++))
  fi
}

update_system_integrations() {
  __process_msg "Updating system integrations in state.json from config.json"
  local system_integrations_length_config=$(cat $CONFIG_FILE | jq '.systemIntegrations | length')
  local system_integrations_length_state=$(cat $STATE_FILE | jq '.systemIntegrations | length')

  for i in $(seq 1 $system_integrations_length_config); do
    local system_integration=$(cat $CONFIG_FILE | jq '.systemIntegrations['"$i-1"']')
    local update=$(cat $STATE_FILE | jq '.systemIntegrations['"$system_integrations_length_state + $i -1"']='"$system_integration"'')
    update=$(echo $update | jq '.' | tee $STATE_FILE)
  done
  __process_msg "Succcessfully updated state.json with systemIntegrations"
}

restore_state() {
  cp $STATE_FILE_BACKUP $STATE_FILE
  update=$(cat $STATE_FILE | jq '.machines='[]'')
  _update_state "$update"
}

main() {
  __process_marker "Getting config"
  get_system_config
  validate_config
  check_state_backup_exists
  if [ $INIT_STATE_FILE -eq 1 ]; then
    bootstrap_state
    update_system_settings
    update_install_status
    update_providers
    update_bbserver_details
    update_system_integrations
  else
    restore_state
  fi
}

main
