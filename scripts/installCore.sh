readonly CORE_CONFIG="$DATA_DIR/core.json"
readonly CORE_COMPONENTS="postgresql \
  vault \
  gitlab \
  swarm \
  rabbitmq"

###########################################################
export CORE_COMPONENTS_LIST=""
export CORE_MACHINES_LIST=""

validate_core_config() {
  #TODO: check if components.json has all the require components 
  echo "validating core config"
  CORE_COMPONENTS_LIST=$(cat $CORE_CONFIG | jq '.')
  local component_count=$(echo $CORE_COMPONENTS_LIST | jq '. | length')
  if [[ $component_count -lt 1 ]]; then
    echo "5 components required to set up shippable, $component_count provided"
    exit 1
  else
    echo "Component count : $component_count"
  fi

}

install_database() {
  echo "getting provisioned machines list"
  local db_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="db")')
  local host=$(echo $db_host | jq '.ip')
  _copy_script_remote $host "installPostgresql.sh" "$SCRIPT_DIR_REMOTE"
  _exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/installPostgresql.sh"

  #TODO: update state
}

install_vault() {
  echo "|___ installing vault"
  local vault_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="db")')
  local host=$(echo $vault_host | jq '.ip')
  _copy_script_remote $host "installVault.sh" "$SCRIPT_DIR_REMOTE"
  _exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/installVault.sh"

  #TODO: save vault creds into state.json (for now)
  #exec_remote_cmd "root" "1.1.1.1" "mykeyfile" "install vault"

  true
}

install_rabbitmq() {
  #TODO: get the machine that db was installed on, and install rabbitmq on it
  # save rabbitmq creds into state.json (for now)
  #exec_remote_cmd "root" "1.1.1.1" "mykeyfile" "install rabbitmq"
  true
}

install_gitlab() {
  echo "|___ installing gitlab"
  local gitlab_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="swarm")')
  local host=$(echo $gitlab_host | jq '.ip')
  _copy_script_remote $host "installGitlab.sh" "$SCRIPT_DIR_REMOTE"
  _exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/installGitlab.sh"

  #TODO: make sure this is the same machine running this installer
  # save gitlab creds in state.json (for now)
  #exec_remote_cmd "root" "1.1.1.2" "mykeyfile" "install gitlab"
  true
}

install_swarm() {
  #TODO: get machine where gitlab was installed, and install swarm on it
  # make sure this is the same machine that is running this installer
  #exec_remote_cmd "root" "1.1.1.2" "mykeyfile" "install swarm"
  true
}

install_redis() {
  #TODO: get machine where gitlab was installed and install redis on it
  #exec_remote_cmd "root" "1.1.1.2" "mykeyfile" "install redis"
  true
}

update_state() {
  # TODO: update state.json with the results
  echo "updating state file with core component status"
}

main() {
  validate_core_config
  install_database
  install_vault
  install_rabbitmq
  install_gitlab
  install_swarm
  install_redis
  update_state
}

main
