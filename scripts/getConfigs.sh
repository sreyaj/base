#!/bin/bash -e

export RELEASE_VERSION="v4.10.29"

###########################################################
validate_version() {
  __process_msg "validating version"
  if [ "$INSTALL_MODE" == "production" ]; then
    if [ ! -f "$USR_DIR/machines.json" ]; then
      echo "Cannot find machines.json, exiting..."
      exit 1
    else
      __process_msg "Found machines.json"
    fi
  fi

  #TODO check versions directory, error if empty
  #TODO check migrations directory, error if empty
}

generate_state() {
  __process_msg "Generating state file"
  __process_msg "Install mode: $INSTALL_MODE"
  if [ ! -f "$USR_DIR/state.json" ]; then
    if [ -f "$USR_DIR/state.json.backup" ]; then
      __process_msg "A state.json.backup file exists, do you want to use the backup? (yes/no)"
      read response
      if [[ "$response" == "yes" ]]; then
        cp -vr $USR_DIR/state.json.backup $USR_DIR/state.json
        rm $USR_DIR/state.json.backup || true
      else
        __process_msg "Dicarding backup, creating a new state.json from state.json.example"
        rm $USR_DIR/state.json.backup || true
        cp -vr $USR_DIR/state.json.example $USR_DIR/state.json
        local update=$(cat $STATE_FILE \
          | jq '.installMode="'$INSTALL_MODE'"')
        update=$(echo $update | jq '.' | tee $STATE_FILE)
      fi
    else
      __process_msg "No state.json exists, creating a new state.json from state.json.example."
      cp -vr $USR_DIR/state.json.example $STATE_FILE
      rm $USR_DIR/state.json.backup || true
      local update=$(cat $STATE_FILE \
        | jq '.installMode="'$INSTALL_MODE'"')
      update=$(echo $update | jq '.' | tee $STATE_FILE)
    fi
  else
    __process_msg "using existing state.json"
  fi
}

validate_install_mode() {
  __process_msg "validating install mode"
  local state_install_mode=$(cat $STATE_FILE \
    | jq -r '.installMode')

  if [ "$INSTALL_MODE" == "$state_install_mode" ]; then
    __process_msg "Install mode verified, proceeding"
  else
    __process_msg "Installer and state.json installMode values different"
    __process_msg "Either run installer in same mode as state.json or "\
      "remove state.json and try again"
    exit 1
  fi
}

bootstrap_state() {
  local release_version=$(cat $STATE_FILE | jq -r '.release')
  if [ -z "$release_version" ]; then
    __process_msg "bootstrapping state.json for latest release"

    ##TODO parse this from versions file
    __process_msg "updating release version"
    release_version="$RELEASE_VERSION"
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

modify_state() {
  if [ "$INSTALL_MODE" == "production" ]; then
    __process_msg "default state.json created, do you want to edit it to to update any values ?"
    __process_msg "enter 'yes' to edit the file, any other key to proceed"
    read response
    if [[ "$response" == "yes" ]]; then
      __process_msg "Edit 'usr/state.json' to update desired values and run installer again"
      exit 0
    else
      __process_msg "state.json manual configuration skipped"
    fi
  else
    __process_msg "Installer running locally, skipping optional configuration edit"
  fi
}

validate_state() {
  __process_msg "validating state.json"
  # parse from jq
  local release_version=$(cat $STATE_FILE | jq -r '.release')
  if [ -z "$release_version" ]; then
    __process_msg "Invalid statefile, no release version specified"
    __process_msg "Please fix the statefile or delete it and try again"
    exit 1
  fi
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

main() {
  __process_marker "Configuring installer"
  validate_version
  generate_state
  validate_install_mode
  bootstrap_state
  modify_state
  validate_state
}

main
