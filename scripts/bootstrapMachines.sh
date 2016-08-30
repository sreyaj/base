#!/bin/bash -e
readonly MACHINES_CONFIG="$DATA_DIR/machines.json"
###########################################################
export MACHINES_LIST=""

validate_machines_config() {
  MACHINES_LIST=$(cat $MACHINES_CONFIG | jq '.')
  local machine_count=$(echo $MACHINES_LIST | jq '. | length')
  if [[ $machine_count -lt 2 ]]; then
    __process_msg "At least 2 machines required to set up shippable, $machine_count provided"
    exit 1
  else
    __process_msg "Machine count: $machine_count"
  fi

  ##TODO: check if there is at least one machine "core" group and "services" group
  __process_msg "Validated machines config"

  ##TODO: if all machines are in consistent state, then skip this
  ##TODO: add machines to list in state



  ## Trying to update file using jq :-/

  ##echo $MACHINES_LIST | \

  #local state=$(cat $STATE_FILE | jq '.')

  ## use select to filter only required elments

  #echo $state | jq '.machines[] |= .+ ["foo": "bar"]' | tee -a something
  #echo $state | jq '. | .machines + [{"foo": "bar"}]'

  #cat $STATE_FILE | \
  # echo $state | \
  #  jq '.machines | map(
  #          . + {"state":"inconsistent"}
  #      )'
}

update_state() {
  # group can be machines, core or services
  local group=$1
  local name=$2
  local data=$3

  ## read from statefile
  ## manipulate data
  ## save

  local state=$(cat $STATE_FILE | jq '.')

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

  __process_msg "All hosts reachable"
}

check_requirements() {
  # TODO: check machine config: memory, cpu disk, arch os type
  __process_msg "Validating machine requirements"
  local machine_count=$(echo $MACHINES_LIST | jq '. | length')
  for i in $(seq 1 $machine_count); do
    local machine=$(echo $MACHINES_LIST | jq '.['"$i-1"']')
    local host=$(echo $machine | jq '.ip')
    _copy_script_remote $host "checkRequirements.sh" "$SCRIPT_DIR_REMOTE"
    _exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/checkRequirements.sh"
  done
}

update_state() {
  # TODO: update state.json with the results
  __process_msg "updating state file with machine status"
}

bootstrap() {
  __process_msg "Installing core components on machines"
  local machine_count=$(echo $MACHINES_LIST | jq '. | length')
  for i in $(seq 1 $machine_count); do
    local machine=$(echo $MACHINES_LIST | jq '.['"$i-1"']')
    local host=$(echo $machine | jq '.ip')
    _copy_script_remote $host "installBase.sh" "$SCRIPT_DIR_REMOTE"
    _exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/installBase.sh"
  done
}

main() {
  __process_marker "Bootstrapping machines"
  validate_machines_config
  create_ssh_keys
  update_ssh_key
  check_connection
  check_requirements
  bootstrap
  update_state
}

main
