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

  #TODO: read migrations file from config and run it on database
  #TODO: update state
}

install_vault() {
  __process_msg "Installing Vault"
  local vault_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="db")')
  local host=$(echo $vault_host | jq '.ip')
  _copy_script_remote $host "installVault.sh" "$SCRIPT_DIR_REMOTE"
  _exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/installVault.sh"

  local db_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="db")')
  local db_ip=$(echo $db_host | jq '.ip')
  local db_port=5432
  local db_username=$(cat $STATE_FILE | jq '.core[] | select (.name=="postgresql") | .secure.username')
  local db_password=$(cat $STATE_FILE | jq '.core[] | select (.name=="postgresql") | .secure.password')

  _copy_script_remote $host "vault.hcl" "/etc/vault.d/"
  _copy_script_remote $host "policy.hcl" "/etc/vault.d/"
  _copy_script_remote $host "vault.sql" "/etc/vault.d/"
  _copy_script_remote $host "vault.conf" "/etc/init/"

  _exec_remote_cmd $host "sed -i \"s/{{DB_USERNAME}}/$db_username/g\" /etc/vault.d/vault.hcl"
  _exec_remote_cmd $host "sed -i \"s/{{DB_PASSWORD}}/$db_password/g\" /etc/vault.d/vault.hcl"
  _exec_remote_cmd $host "sed -i \"s/{{DB_ADDRESS}}/$db_ip:$db_port/g\" /etc/vault.d/vault.hcl"
  _exec_remote_cmd $host "sudo service vault start"

  # _copy_script_remote $host "bootstrapVault.sh" "$SCRIPT_DIR_REMOTE"
  # _exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/bootstrapVault.sh"
  # _exec_remote_cmd "$host" "psql -h localhost $SCRIPT_DIR_REMOTE/bootstrapVault.sh"

  #TODO: save vault creds into state.json (for now)
  #exec_remote_cmd "root" "1.1.1.1" "mykeyfile" "install vault"
}

install_rabbitmq() {
  __process_msg "Installing RabbitMQ"
  local db_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="db")')
  local host=$(echo $db_host | jq '.ip')
  _copy_script_remote $host "installRabbit.sh" "$SCRIPT_DIR_REMOTE"
  _exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/installRabbit.sh"

  _copy_script_remote $host "rabbitmqadmin" "$SCRIPT_DIR_REMOTE"

  _copy_script_remote $host "bootstrapRabbit.sh" "$SCRIPT_DIR_REMOTE"
  _exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/bootstrapRabbit.sh"
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

install_docker() {
  __process_msg "Installing Docker on management machine"
  local gitlab_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="swarm")')
  local host=$(echo $gitlab_host | jq '.ip')
  _copy_script_remote $host "installDocker.sh" "$SCRIPT_DIR_REMOTE"
  _exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/installDocker.sh"

  __process_msg "Installing Docker on service machines"
  local service_machines_list=$(cat $STATE_FILE | jq '[ .machines[] | select(.group=="services") ]')
  local service_machines_count=$(echo $service_machines_list | jq '. | length')
  for i in $(seq 1 $service_machines_count); do
    local machine=$(echo $service_machines_list | jq '.['"$i-1"']')
    local host=$(echo $machine | jq '.ip')
    _copy_script_remote $host "installDocker.sh" "$SCRIPT_DIR_REMOTE"
    _exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/installDocker.sh"
  done
}

install_swarm() {
  __process_msg "Installing Swarm"
  local gitlab_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="swarm")')
  local host=$(echo $gitlab_host | jq '.ip')
  _copy_script_remote $host "installSwarm.sh" "$SCRIPT_DIR_REMOTE"
  _exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/installSwarm.sh"


  #TODO create swarm cluster, make the host on running on gitlab machine as manager
  # add all other servers as workers
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
  install_docker
  install_swarm
  install_redis
  update_state
}

main
