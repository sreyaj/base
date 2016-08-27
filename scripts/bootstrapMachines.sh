#!/bin/bash -e
readonly MACHINES_CONFIG="$DATA_DIR/machines.json"

validate_machines_config() {
  #TODO: check if machines.json has at least two machines, 
  # one for group "core" and one for group "services"
  echo "validated machines config"
}

get_machines_list() {
  ##TODO: read machines.json,
  ## throw error if no machines,
  echo "fetched machines list from machines.json"
}

create_ssh_keys() {
  ##TODO: check if 
  ## data/machinesKey and data/machinesKey.pub
  ## are present, if not create the two keys
  ## set right permissions
  echo "Creating ssh keys"
}

update_ssh_key() {
  ##TODO: ask user to update ssh keys in machines
  echo ">update ssh keys in all the machines"
}

check_connection() {
  # TODO: check if ssh into each machine works or not
  echo "checking machine connection"
}

check_requirements() {
  # TODO: check machine config: memory, cpu disk, arch os type
  echo "validating machine requirements"
}

update_state() {
  # TODO: update state.json with the results
  echo "updating state file with machine status"
}

bootstrap() {
  # TODO: bootstrap each machine to
  # run apt-get update
  # install jq

  echo "Installing core components on machines"
}

main() {
  validate_machines_config
  get_machines_list
  create_ssh_keys
  update_ssh_key
  check_connection
  check_requirements
  bootstrap
  update_state
}

main
