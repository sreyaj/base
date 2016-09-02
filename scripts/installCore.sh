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
  CORE_COMPONENTS_LIST=$(cat "$CORE_CONFIG" | jq '.')
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
  ##TODO:
  # - prommt user for db username and password
  # - copy the installation script to remote machine
  # - run sed command to replace username/password with user input
  # - once complete, save the values in satefile
  _copy_script_remote $host "installPostgresql.sh" "$SCRIPT_DIR_REMOTE"
  _exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/installPostgresql.sh"
}


save_db_credentials_in_statefile() {
  __process_msg "Saving database credentials in state file"
  local db_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="db")')
  local host=$(echo $db_host | jq '.ip')
  local db_ip=$(echo $db_host | jq -r '.ip')
  local db_port=5432
  local db_address=$db_ip":"$db_port

  db_username="apiuser"
  db_password="testing1234"

  result=$(cat $STATE_FILE | jq ".systemSettings.dbUsername = \"$db_username\"")
  echo $result > $STATE_FILE

  result=$(cat $STATE_FILE | jq ".systemSettings.dbPassword = \"$db_password\"")
  echo $result > $STATE_FILE

  # We will need to wrap user constructed variables around "".
  # The values extracted from json are already in string format.
  result=$(cat $STATE_FILE | jq ".systemSettings.dbUrl = \"$db_address\"")
  echo $result > $STATE_FILE
}

save_db_credentials() {
  __process_msg "Saving database credentials"
  local db_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="db")')
  local host=$(echo $db_host | jq '.ip')
  local db_ip=$(echo $db_host | jq '.ip')
  local db_port=5432
  local db_username=$(cat $STATE_FILE | jq '.systemSettings.dbUsername')
  local db_password=$(cat $STATE_FILE | jq '.systemSettings.dbPassword')
  local db_address=$db_ip:$db_port

  #TODO: fetch db_name from state.json
  local db_name="shipdb"

  _copy_script_remote $host ".pgpass" "/root/"
  _exec_remote_cmd $host "sed -i \"s/{{address}}/$db_address/g\" /root/.pgpass"
  _exec_remote_cmd $host "sed -i \"s/{{database}}/$db_name/g\" /root/.pgpass"
  _exec_remote_cmd $host "sed -i \"s/{{username}}/$db_username/g\" /root/.pgpass"
  _exec_remote_cmd $host "sed -i \"s/{{password}}/$db_password/g\" /root/.pgpass"

  _exec_remote_cmd $host "chmod 0600 /root/.pgpass"
}

run_migrations() {
  __process_msg "Please copy migrations.sql onto machine which runs database, type (y) when done"
  __process_msg "Done? (y/n)"
  read response
  if [[ "$response" =~ "y" ]]; then
    __process_msg "Proceeding with steps to run migrations"
    #TODO: Run migrations on db
  else
    __process_msg "Migrations are required to install core"
    run_migrations
  fi
}

insert_system_config() {
  __process_msg "Inserting data into systemConfigs Table"
  local db_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="db")')
  local host=$(echo $db_host | jq '.ip')
  local db_ip=$(echo $db_host | jq '.ip')
  local db_username=$(cat $STATE_FILE | jq '.core[] | select (.name=="postgresql") | .secure.username')

  #TODO: fetch db_name from state.json
  local db_name="shipdb"

  _copy_script_remote $host "system_configs_data.sql" "/tmp"
  _exec_remote_cmd $host "psql -U $db_username -h $db_ip -d $db_name -f /tmp/system_configs_data.sql"
}

install_vault() {
  __process_msg "Installing Vault"
  local vault_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="db")')
  local host=$(echo $vault_host | jq '.ip')
  _copy_script_remote $host "installVault.sh" "$SCRIPT_DIR_REMOTE"
  _exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/installVault.sh"

  local vault_url=$host

  local db_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="db")')
  local db_ip=$(echo $db_host | jq '.ip')
  local db_port=5432
  local db_username=$(cat $STATE_FILE | jq '.systemSettings.dbUsername')
  local db_address=$db_ip:$db_port

  #TODO: fetch db_name from state.json
  local db_name="shipdb"
  local VAULT_JSON_FILE="/vault/config/scripts/vaultConfig.json"

  _copy_script_remote $host "vault.hcl" "/etc/vault.d/"
  _copy_script_remote $host "policy.hcl" "/etc/vault.d/"
  _copy_script_remote $host "vault.sql" "/etc/vault.d/"
  _copy_script_remote $host "vault.conf" "/etc/init/"
  _copy_script_remote $host "system_config.sql.template" "/vault/config/scripts/"
  _copy_script_remote $host "vaultConfig.json.template" "/vault/config/scripts/"

  _exec_remote_cmd $host "sed -i \"s/{{DB_USERNAME}}/$db_username/g\" /etc/vault.d/vault.hcl"
  _exec_remote_cmd $host "sed -i \"s/{{DB_PASSWORD}}/$db_password/g\" /etc/vault.d/vault.hcl"
  _exec_remote_cmd $host "sed -i \"s/{{DB_ADDRESS}}/$db_address/g\" /etc/vault.d/vault.hcl"

  _exec_remote_cmd $host "psql -U $db_username -h $db_ip -d $db_name -w -f /etc/vault.d/vault.sql"

  _exec_remote_cmd $host "sudo service vault start || true"

  _copy_script_remote $host "bootstrapVault.sh" "$SCRIPT_DIR_REMOTE"
  _exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/bootstrapVault.sh $db_username $db_name $db_ip $vault_url"

  _copy_script_local $host $VAULT_JSON_FILE
}

save_vault_credentials() {
  __process_msg "Saving vault credentials in state.json"
  local VAULT_FILE="/tmp/shippable/vaultConfig.json"

  local vault_url=$(cat $VAULT_FILE | jq '.vaultUrl')
  local vault_token=$(cat $VAULT_FILE | jq '.vaultToken')

  result=$(cat $STATE_FILE | jq ".systemSettings.vaultUrl = $vault_url")
  echo $result | jq '.' > $STATE_FILE

  result=$(cat $STATE_FILE | jq ".systemSettings.vaultToken = $vault_token")
  echo $result | jq '.' > $STATE_FILE
  __process_msg "Vault credentials successfully saved to state.json"
}

install_rabbitmq() {
  __process_msg "Installing RabbitMQ"
  local db_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="db")')
  local host=$(echo $db_host | jq -r '.ip')
  _copy_script_remote $host "installRabbit.sh" "$SCRIPT_DIR_REMOTE"
  _exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/installRabbit.sh"

  _copy_script_remote $host "rabbitmqadmin" "$SCRIPT_DIR_REMOTE"

  # TODO: The user should be prompted to enter a username and password, which should be
  # used by the bootstrapRabbit.sh
  _copy_script_remote $host "bootstrapRabbit.sh" "$SCRIPT_DIR_REMOTE"
  _exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/bootstrapRabbit.sh"

  amqpUrl="amqp://SHIPPABLETESTUSER:SHIPPABLETESTPASS@$host:15672/shippableRoot"
  result=$(cat $STATE_FILE | jq ".systemSettings.amqpUrl = \"$amqpUrl\"")
  echo $result | jq '.' > $STATE_FILE
}

save_gitlab_state() {
  #TODO: Get gitlab root username, password from user input
  local gitlab_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="swarm")')
  local host=$(echo "$gitlab_host" | jq '.ip')
  local gitlab_root_username="root"
  local gitlab_root_password="shippable"
  local gitlab_external_url=$(echo $host | tr -d "\"")
  gitlab_external_url="http//$gitlab_external_url/api/v3"

  local gitlab_integration=$(cat $STATE_FILE | jq '
    .systemIntegrations |= . + [{
      "name": "gitlab",
      "data": {
        "username": "'$gitlab_root_username'",
        "subscriptionProjectLimit": "100",
        "password": "'$gitlab_root_password'",
        "url": "'$gitlab_external_url'"
      }
    }]')
  _update_state "$gitlab_integration"
}

install_gitlab() {
  __process_msg "Installing Gitlab"
  local gitlab_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="swarm")')
  local host=$(echo $gitlab_host | jq -r '.ip')
  local gitlab_system_int=$(cat $STATE_FILE | jq '.systemIntegrations[] | select (.name=="gitlab")')
  local gitlab_root_username=$(echo $gitlab_system_int | jq -r '.data.username')
  local gitlab_root_password=$(echo $gitlab_system_int | jq -r '.data.password')
  local gitlab_external_url=$(echo $gitlab_system_int | jq -r '.data.url')

  _copy_script_remote $host "installGitlab.sh" "$SCRIPT_DIR_REMOTE"
  _copy_script_remote $host "gitlab.rb" "/etc/gitlab/"

  _exec_remote_cmd $host "sed -i \"s/{{gitlab_machine_url}}/$host/g\" /etc/gitlab/gitlab.rb"
  _exec_remote_cmd $host "sed -i \"s/{{gitlab_password}}/$gitlab_root_password/g\" /etc/gitlab/gitlab.rb"
  _exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/installGitlab.sh"

  #TODO: make sure this is the same machine running this installer
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

  __process_msg "Initializing docker swarm master"
  local swarm_init_cmd="sudo docker swarm init --advertise-addr $host"
  _exec_remote_cmd "$host" "$swarm_init_cmd"

  local swarm_worker_token="swarm_worker_token.txt"
  local swarm_worker_token_remote="$SCRIPT_DIR_REMOTE/$swarm_worker_token"
  _exec_remote_cmd "$host" "sudo docker swarm join-token -q worker > $swarm_worker_token_remote"
  _copy_script_local $host "$swarm_worker_token_remote"

  local script_dir_local="/tmp/shippable"
  local swarm_worker_token_local="$script_dir_local/$swarm_worker_token"
  local swarm_worker_token=$(cat $swarm_worker_token_local)

  local swarm_worker_token_update=$(cat $STATE_FILE | jq '
    .systemSettings.swarmWorkerToken = "'$swarm_worker_token'"')
  echo $swarm_worker_token_update > $STATE_FILE
}

initialize_workers() {
  __process_msg "Initializing swarm workers on service machines"
  local gitlab_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="swarm")')
  local gitlab_host_ip=$(echo $gitlab_host | jq -r '.ip')

  local service_machines_list=$(cat $STATE_FILE | jq '[ .machines[] | select(.group=="services") ]')
  local service_machines_count=$(echo $service_machines_list | jq '. | length')
  for i in $(seq 1 $service_machines_count); do
    local machine=$(echo $service_machines_list | jq '.['"$i-1"']')
    local host=$(echo $machine | jq '.ip')
    local swarm_worker_token=$(cat $STATE_FILE | jq '.systemSettings.swarmWorkerToken')
    _exec_remote_cmd "$host" "sudo docker swarm join --token $swarm_worker_token $gitlab_host_ip"
  done
}

install_redis() {
  __process_msg "Installing Redis"
  local redis_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="swarm")')
  local host=$(echo $redis_host | jq '.ip')
  _copy_script_remote $host "redis.conf" "/etc/redis"
  _copy_script_remote $host "installRedis.sh" "$SCRIPT_DIR_REMOTE"
  _exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/installRedis.sh"
}

install_rp() {
  __process_msg "Installing reverse proxy"
  # TODO:
  # - read domain name
  # - on the first services node, 
  # - update nginx config file
  # - update docker file
  # - run docker build
  # - run rp on first services
}

update_state() {
  # TODO: update state.json with the results
  echo "updating state file with core component status"
}

main() {
  __process_marker "Installing core"
  validate_core_config
  install_database
  save_db_credentials_in_statefile
  save_db_credentials
  # insert_system_config
  # run_migrations
  install_vault
  save_vault_credentials
  install_rabbitmq
  save_gitlab_state
  install_gitlab
  install_docker
  install_swarm
  initialize_workers
  install_redis
  install_rp
  update_state
}

main
