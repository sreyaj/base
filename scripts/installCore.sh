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
  # TODO: check if components.json has all the require components
  __process_msg "Validating core config"
  CORE_COMPONENTS_LIST=$(cat $CORE_CONFIG | jq '.')
  local component_count=$(echo $CORE_COMPONENTS_LIST | jq '. | length')
  if [[ $component_count -lt 1 ]]; then
    __process_msg "5 components required to set up Shippable, $component_count provided"
    exit 1
  else
    __process_msg "Component count: $component_count"
  fi

}

install_database() {
  __process_msg "Installing Database"
  local db_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="db")')
  local host=$(echo $db_host | jq '.ip')
  _copy_script_remote $host "installPostgresql.sh" "$SCRIPT_DIR_REMOTE"
  _exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/installPostgresql.sh"

  #TODO: update state
}

install_vault() {
  __process_msg "Installing Vault"
  local vault_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="db")')
  local host=$(echo $vault_host | jq '.ip')
  _copy_script_remote $host "installVault.sh" "$SCRIPT_DIR_REMOTE"
  _exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/installVault.sh"

  #TODO: save vault creds into state.json (for now)
  #exec_remote_cmd "root" "1.1.1.1" "mykeyfile" "install vault"

}

install_rabbitmq() {
  __process_msg "Installing RabbitMQ"
  local db_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="db")')
  local host=$(echo $db_host | jq '.ip')
  _copy_script_remote $host "installRabbit.sh" "$SCRIPT_DIR_REMOTE"
  _exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/installRabbit.sh"
}

install_gitlab() {
  __process_msg "Installing Gitlab"
  local gitlab_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="swarm")')
  local host=$(echo $gitlab_host | jq '.ip')
  _copy_script_remote $host "installGitlab.sh" "$SCRIPT_DIR_REMOTE"
  _exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/installGitlab.sh"

  #TODO: make sure this is the same machine running this installer
  # save gitlab creds in state.json (for now)
  #exec_remote_cmd "root" "1.1.1.2" "mykeyfile" "install gitlab"
}

install_swarm() {
  __process_msg "Installing Swarm"
  #TODO: get machine where gitlab was installed, and install swarm on it
  # make sure this is the same machine that is running this installer
  #exec_remote_cmd "root" "1.1.1.2" "mykeyfile" "install swarm"
  true
}

install_redis() {
  __process_msg "Installing Redis"
  local redis_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="swarm")')
  local host=$(echo $redis_host | jq '.ip')
  _copy_remote $host "$DATA_DIR/redis.conf" "/etc/redis/redis.conf"
  _copy_remote $host "$SCRIPTS_DIR/remote/installRedis.sh" "$REMOTE_DIR"
  _exec_remote_cmd "$host" "$REMOTE_DIR/installRedis.sh"
}

update_state() {
  # TODO: update state.json with the results
  echo "updating state file with core component status"
}

main() {
  __process_marker "Installing core"
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
