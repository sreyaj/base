readonly CORE_CONFIG="$DATA_DIR/core.json"
readonly CORE_COMPONENTS="postgresql \
  vault \
  gitlab \
  swarm \
  rabbitmq"

validate_core_config() {
  #TODO: check if components.json has all the require components 
  echo "validating core config"
}

get_machine_list() {
  #TODO: get machines list from state.json. these will the machines
  #that are currently running and in consistent state
  echo "getting provisioned machines list"
}

install_database() {
  #TODO: get one core machine, and install database on it
  # use ssh keys to log into the database box
  # run the script to install postgres
  # save the db username/password into state.json (for now)
  echo "installing postgres"
  exec_remote_cmd "root" "1.1.1.1" "mykeyfile" "install pgsql"
}

install_vault() {
  #TODO: get the machine that db was installed on, and install vault on it
  # save vault creds into state.json (for now)
  exec_remote_cmd "root" "1.1.1.1" "mykeyfile" "install vault"
}

install_rabbitmq() {
  #TODO: get the machine that db was installed on, and install rabbitmq on it
  # save rabbitmq creds into state.json (for now)
  exec_remote_cmd "root" "1.1.1.1" "mykeyfile" "install rabbitmq"
}

install_gitlab() {
  #TODO: get another machine from core group, and install gitlab
  # make sure this is the same machine running this installer
  # save gitlab creds in state.json (for now)
  exec_remote_cmd "root" "1.1.1.2" "mykeyfile" "install gitlab"
}

install_swarm() {
  #TODO: get machine where gitlab was installed, and install swarm on it
  # make sure this is the same machine that is running this installer
  exec_remote_cmd "root" "1.1.1.2" "mykeyfile" "install swarm"
}

install_redis() {
  #TODO: get machine where gitlab was installed and install redis on it
  exec_remote_cmd "root" "1.1.1.2" "mykeyfile" "install redis"
}

update_state() {
  # TODO: update state.json with the results
  echo "updating state file with core component status"
}

main() {
  validate_core_config
  get_machine_list
  install_database
  install_vault
  install_rabbitmq
  install_gitlab
  install_swarm
  install_redis
  update_state
}

main
