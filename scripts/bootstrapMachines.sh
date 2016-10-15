#!/bin/bash -e
readonly MACHINES_CONFIG="$USR_DIR/machines.json"
###########################################################
export MACHINES_LIST=""

validate_machines_config() {
  __process_msg "validating machines config"
  MACHINES_LIST=$(cat $MACHINES_CONFIG | jq '.')
  local machine_count=$(echo $MACHINES_LIST | jq -r '. | length')
  if [[ $machine_count -lt 2 ]]; then
    __process_msg "At least 2 machines required to set up shippable, $machine_count provided"
    exit 1
  else
    __process_msg "Machine count: $machine_count"
  fi

  __process_msg "Cleaning up machines array in state.json"
  local update=$(cat $STATE_FILE \
    | jq '.machines=[]')
  _update_state "$update"

  ##TODO: check if there is at least one machine "core" group and "services" group
  ##TODO: if all machines are in consistent state, then skip this
  __process_msg "Validated machines config"

  for i in $(seq 1 $machine_count); do
    local machine=$(echo $MACHINES_LIST | jq '.['"$i-1"']')
    local host=$(echo $machine | jq '.ip')
    local name=$(echo $machine | jq '.name')
    local group=$(echo $machine | jq '.group')

    local machines_state=$(cat $STATE_FILE | jq '
      .machines |= . + [{
        "name": '"$name"',
        "group": '"$group"',
        "ip": '"$host"',
        "keysUpdated": "false",
        "sshSuccessful": "false",
        "isConsistent": "false"
      }]')

    local update=$(echo $machines_state \
      | jq '.')
    _update_state "$update"
  done
}

create_ssh_keys() {
  __process_msg "Creating SSH keys"
  if [ -f "$SSH_PRIVATE_KEY" ] && [ -f $SSH_PUBLIC_KEY ]; then
    __process_msg "SSH keys already present, skipping"
  else
    __process_msg "SSH keys not available, generating"
    local keygen_exec=$(ssh-keygen -t rsa -P "" -f $SSH_PRIVATE_KEY)
    __process_msg "SSH keys successfully generated"
  fi
  #TODO: update state
}

update_ssh_key() {
  ##TODO: ask user to update ssh keys in machines
  __process_msg "Please run the following command on all the machines (including this one), type (y) when done"
  echo ""
  echo "echo `cat $SSH_PUBLIC_KEY` | sudo tee -a /root/.ssh/authorized_keys"
  echo ""

  __process_msg "Done? (y/n)"
  read response
  if [[ "$response" =~ "y" ]]; then
    __process_msg "Proceeding with steps to set up the machines"
  else
    __process_msg "SSH keys are required to bootstrap the machines"
    update_ssh_key
  fi

  ##TODO: update state
}

check_connection() {
  # TODO: check if ssh into each machine works or not
  __process_msg "Checking machine connection"
  local machine_count=$(echo $MACHINES_LIST | jq '. | length')
  for i in $(seq 1 $machine_count); do
    local machine=$(echo $MACHINES_LIST | jq '.['"$i-1"']')
    local host=$(echo $machine | jq '.ip')
    _exec_remote_cmd "$host" "ls"
  done

  local update=$(cat $STATE_FILE | jq '.installStatus.machinesSSHSuccessful='true'')
  _update_state "$update"

  __process_msg "All hosts reachable"
}

check_requirements() {
  # TODO: check machine config: memory, cpu disk, arch os type
  __process_msg "Validating machine requirements"
  local machine_count=$(echo $MACHINES_LIST | jq '. | length')
  for i in $(seq 1 $machine_count); do
    local machine=$(echo $MACHINES_LIST | jq '.['"$i-1"']')
    local host=$(echo $machine | jq '.ip')
    _copy_script_remote $host "$REMOTE_SCRIPTS_DIR/checkRequirements.sh" "$SCRIPT_DIR_REMOTE"
    _exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/checkRequirements.sh"
  done
}

export_language() {
  __process_msg "Exporting Language Preferences"
  local machine_count=$(echo $MACHINES_LIST | jq '. | length')
  for i in $(seq 1 $machine_count); do
    local machine=$(echo $MACHINES_LIST | jq '.['"$i-1"']')
    local host=$(echo $machine | jq '.ip')
    _exec_remote_cmd "$host" "export LC_ALL=C"
  done
}

setup_node() {
  __process_msg "Configuring ulimits on machines"
  local machine_count=$(echo $MACHINES_LIST | jq '. | length')
  for i in $(seq 1 $machine_count); do
    local machine=$(echo $MACHINES_LIST | jq '.['"$i-1"']')
    local host=$(echo $machine | jq '.ip')
    _copy_script_remote $host "$REMOTE_SCRIPTS_DIR/setupNode.sh" "$SCRIPT_DIR_REMOTE"
    _exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/setupNode.sh"
  done
}

bootstrap() {
  __process_msg "Installing core components on machines"
  local machine_count=$(echo $MACHINES_LIST | jq '. | length')
  for i in $(seq 1 $machine_count); do
    local machine=$(echo $MACHINES_LIST | jq '.['"$i-1"']')
    local host=$(echo $machine | jq '.ip')
    _copy_script_remote $host "$REMOTE_SCRIPTS_DIR/installBase.sh" "$SCRIPT_DIR_REMOTE"
    _exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/installBase.sh $INSTALL_MODE"
  done
}

bootstrap_local() {
  __process_msg "Installing core components on machines"
  source "$REMOTE_SCRIPTS_DIR/installBase.sh" "$INSTALL_MODE"
  sudo rm -rf "$LOCAL_SCRIPTS_DIR/gitlab" || true
}

main() {
  __process_marker "Bootstrapping machines"
  local machines_bootstrap_status=$(cat $STATE_FILE \
    | jq -r '.installStatus.machinesBootstrapped')

  if [ $machines_bootstrap_status == true ]; then
    __process_msg "Machines already bootstrapped"
  else
    __process_msg "Machines not bootstrapped"
    __process_msg "Bootstrapping machines for $INSTALL_MODE"
    if [ "$INSTALL_MODE" == "production" ]; then
      validate_machines_config
      create_ssh_keys
      update_ssh_key
      check_connection
      check_requirements
      export_language
      setup_node
      bootstrap
    else
      bootstrap_local
    fi

    local update=$(cat $STATE_FILE \
      | jq '.installStatus.machinesBootstrapped=true')
    _update_state "$update"
  fi
}

main
