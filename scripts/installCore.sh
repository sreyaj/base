readonly CORE_CONFIG="$DATA_DIR/core.json"
readonly CORE_COMPONENTS="postgresql \
  vault \
  gitlab \
  swarm \
  rabbitmq"

###########################################################
export CORE_COMPONENTS_LIST=""
export CORE_MACHINES_LIST=""
export skip_step=0

_update_install_status() {
  local update=$(cat $STATE_FILE | jq '.installStatus.'"$1"'='true'')
  _update_state "$update"
}

_check_component_status() {
  local status=$(cat $STATE_FILE | jq '.installStatus.'"$1"'')
  if [ "$status" = true ]; then
    skip_step=1;
  fi
}

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
  skip_step=0
  _check_component_status "databaseInitialized"
  if [ $skip_step -eq 0 ]; then
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
    __process_msg "Waiting 30s for postgres to boot"
    sleep 30s
    _update_install_status "databaseInstalled"
    _update_install_status "databaseInitialized"
  else
    __process_msg "Database already installed, skipping"
    __process_msg "Database already initialized, skipping"
  fi
}

save_db_credentials_in_statefile() {
  __process_msg "Saving database credentials in state file"
  local db_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="db")')
  local db_ip=$(echo $db_host | jq -r '.ip')
  local db_port=5432
  local db_address=$db_ip":"$db_port

  db_name="shipdb"
  db_username="apiuser"
  db_password="testing1234"
  db_dialect="postgres"

  result=$(cat $STATE_FILE | jq '.systemSettings.dbHost = "'$db_ip'"')
  update=$(echo $result | jq '.' | tee $STATE_FILE)

  result=$(cat $STATE_FILE | jq '.systemSettings.dbDialect = "'$db_dialect'"')
  update=$(echo $result | jq '.' | tee $STATE_FILE)

  result=$(cat $STATE_FILE | jq '.systemSettings.dbPort = "'$db_port'"')
  update=$(echo $result | jq '.' | tee $STATE_FILE)

  result=$(cat $STATE_FILE | jq '.systemSettings.dbname = "'$db_name'"')
  update=$(echo $result | jq '.' | tee $STATE_FILE)

  result=$(cat $STATE_FILE | jq '.systemSettings.dbUsername = "'$db_username'"')
  update=$(echo $result | jq '.' | tee $STATE_FILE)

  result=$(cat $STATE_FILE | jq '.systemSettings.dbPassword = "'$db_password'"')
  update=$(echo $result | jq '.' | tee $STATE_FILE)

  result=$(cat $STATE_FILE | jq '.systemSettings.dbUrl = "'$db_address'"')
  update=$(echo $result | jq '.' | tee $STATE_FILE)
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

install_vault() {
  local vault_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="db")')
  local host=$(echo $vault_host | jq '.ip')

  skip_step=0
  _check_component_status "vaultInstalled"
  if [ $skip_step -eq 0 ]; then
    __process_msg "Installing Vault"
    _copy_script_remote $host "installVault.sh" "$SCRIPT_DIR_REMOTE"
    _exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/installVault.sh"
    _update_install_status "vaultInstalled"
  else
    __process_msg "Vault already installed, skipping"
  fi

  skip_step=0
  _check_component_status "vaultInitialized"
  if [ $skip_step -eq 0 ]; then
    local vault_url=$host

    local db_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="db")')
    local db_ip=$(echo $db_host | jq '.ip')
    local db_port=5432
    local db_username=$(cat $STATE_FILE | jq '.systemSettings.dbUsername')
    local db_address=$db_ip:$db_port

    local db_name="shipdb"
    local VAULT_JSON_FILE="/etc/vault.d/vaultConfig.json"

    _copy_script_remote $host "vault.hcl" "/etc/vault.d/"
    _copy_script_remote $host "policy.hcl" "/etc/vault.d/"
    _copy_script_remote $host "vault_kv_store.sql" "/etc/vault.d/"
    _copy_script_remote $host "vault.conf" "/etc/init/"
    _copy_script_remote $host "vaultConfig.json" "/etc/vault.d/"

    _exec_remote_cmd $host "sed -i \"s/{{DB_USERNAME}}/$db_username/g\" /etc/vault.d/vault.hcl"
    _exec_remote_cmd $host "sed -i \"s/{{DB_PASSWORD}}/$db_password/g\" /etc/vault.d/vault.hcl"
    _exec_remote_cmd $host "sed -i \"s/{{DB_ADDRESS}}/$db_address/g\" /etc/vault.d/vault.hcl"

    _exec_remote_cmd $host "psql -U $db_username -h $db_ip -d $db_name -w -f /etc/vault.d/vault_kv_store.sql"

    _exec_remote_cmd $host "service vault start || true"

    _copy_script_remote $host "bootstrapVault.sh" "$SCRIPT_DIR_REMOTE"
    _exec_remote_cmd_proxyless "$host" "$SCRIPT_DIR_REMOTE/bootstrapVault.sh $db_username $db_name $db_ip $vault_url"
    _update_install_status "vaultInitialized"
  else
    __process_msg "Vault already initialized, skipping"
  fi
}

save_vault_credentials() {
  __process_msg "Saving vault credentials in state.json"
  local VAULT_FILE="/tmp/shippable/vaultConfig.json"
  local VAULT_JSON_FILE="/etc/vault.d/vaultConfig.json"

  local vault_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="db")')
  local host=$(echo $vault_host | jq -r '.ip')
  local vault_url="http://$host:8200"
  result=$(cat $STATE_FILE | jq -r '.systemSettings.vaultUrl = "'$vault_url'"')
  update=$(echo $result | jq '.' | tee $STATE_FILE)

  _copy_script_local $host $VAULT_JSON_FILE

  local vault_token=$(cat $VAULT_FILE | jq -r '.vaultToken')
  result=$(cat $STATE_FILE | jq -r '.systemSettings.vaultToken = "'$vault_token'"')
  update=$(echo $result | jq '.' | tee $STATE_FILE)
  __process_msg "Vault credentials successfully saved to state.json"
}

install_rabbitmq() {
  local db_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="db")')
  local host=$(echo $db_host | jq -r '.ip')

  skip_step=0
  _check_component_status "rabbitmqInstalled"
  if [ $skip_step -eq 0 ]; then
    __process_msg "Installing RabbitMQ"
    _copy_script_remote $host "installRabbit.sh" "$SCRIPT_DIR_REMOTE"
    _exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/installRabbit.sh"
    _update_install_status "rabbitmqInstalled"
  else
    __process_msg "RabbitMQ already installed, skipping"
  fi

  _copy_script_remote $host "rabbitmqadmin" "$SCRIPT_DIR_REMOTE"

  # TODO: The user should be prompted to enter a username and password, which should be
  # used by the bootstrapRabbit.sh
  skip_step=0
  _check_component_status "rabbitmqInitialized"
  if [ $skip_step -eq 0 ]; then
    _copy_script_remote $host "bootstrapRabbit.sh" "$SCRIPT_DIR_REMOTE"
    _exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/bootstrapRabbit.sh"
    _update_install_status "rabbitmqInitialized"
  else
    __process_msg "RabbitMQ already initialized, skipping"
  fi

  local amqp_user="SHIPPABLETESTUSER"
  local amqp_pass="SHIPPABLETESTPASS"
  local amqp_exchange="shippableEx"
  local amqp_port=5672
  local amqp_port_admin=15672

  local amqp_url="amqp://$amqp_user:$amqp_pass@$host:$amqp_port/shippable"
  local update=$(cat $STATE_FILE | jq '.systemSettings.amqpUrl = "'$amqp_url'"')
  update=$(echo $update | jq '.' | tee $STATE_FILE)

  local amqp_url_root="amqp://$amqp_user:$amqp_pass@$host:$amqp_port/shippableRoot"
  update=$(cat $STATE_FILE | jq '.systemSettings.amqpUrlRoot = "'$amqp_url_root'"')
  update=$(echo $update | jq '.' | tee $STATE_FILE)

  local amqp_url_admin="http://$amqp_user:$amqp_pass@$host:$amqp_port_admin"
  update=$(cat $STATE_FILE | jq '.systemSettings.amqpUrlAdmin = "'$amqp_url_admin'"')
  update=$(echo $update | jq '.' | tee $STATE_FILE)

  update=$(cat $STATE_FILE | jq '.systemSettings.amqpDefaultExchange = "'$amqp_exchange'"')
  update=$(echo $update | jq '.' | tee $STATE_FILE)
}

save_gitlab_state() {
  #TODO: Get gitlab root username, password from user input
  local gitlab_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="swarm")')
  local host=$(echo "$gitlab_host" | jq '.ip')
  local gitlab_root_username="root"
  local gitlab_root_password="shippable1234"
  local gitlab_external_url=$(echo $host | tr -d "\"")
  gitlab_external_url="http://$gitlab_external_url/api/v3"

  local gitlab_integration=$(cat $STATE_FILE | jq '
    .systemIntegrations |= . + [{
      "name": "gitlab",
      "masterIntegrationId": "574ee696d49b091400b75f19",
      "masterDisplayName": "Internal Gitlab Server",
      "masterName": "Git store",
      "masterType": "scm",
      "isEnabled": true,
      "formJSONValues": [
        {
          "label": "username",
          "value": "'$gitlab_root_username'"
        },
        {
          "label": "subscriptionProjectLimit",
          "value": "100"
        },
        {
          "label": "password",
          "value": "'$gitlab_root_password'"
        },
        {
          "label": "url",
          "value": "'$gitlab_external_url'"
        },
        {
          "label": "sshPort",
          "value": "22"
        }
      ]
    }]')
  _update_state "$gitlab_integration"
}

install_gitlab() {
  skip_step=0
  _check_component_status "gitlabInitialized"
  if [ $skip_step -eq 0 ]; then
    __process_msg "Installing Gitlab"
    local gitlab_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="swarm")')
    local host=$(echo $gitlab_host | jq -r '.ip')
    local gitlab_system_int=$(cat $STATE_FILE | jq '.systemIntegrations[] | select (.name=="gitlab")')

    local gitlab_root_password=$(echo $gitlab_system_int | jq -r '.formJSONValues[]| select (.label=="password")|.value')
    local gitlab_external_url=$(echo $gitlab_system_int | jq -r '.formJSONValues[]| select (.label=="url")|.value')

    _copy_script_remote $host "installGitlab.sh" "$SCRIPT_DIR_REMOTE"
    _copy_script_remote $host "gitlab.rb" "/etc/gitlab/"

    _exec_remote_cmd $host "sed -i \"s/{{gitlab_machine_url}}/$host/g\" /etc/gitlab/gitlab.rb"
    _exec_remote_cmd $host "sed -i \"s/{{gitlab_password}}/$gitlab_root_password/g\" /etc/gitlab/gitlab.rb"
    _exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/installGitlab.sh"
    _update_install_status "gitlabInstalled"
    _update_install_status "gitlabInitialized"
  else
    __process_msg "Gitlab already installed, skipping"
    __process_msg "Gitlab already initialized, skipping"
  fi
}

install_docker() {
  skip_step=0
  _check_component_status "dockerInitialized"
  if [ $skip_step -eq 0 ]; then
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
    _update_install_status "dockerInstalled"
    _update_install_status "dockerInitialized"
  else
    __process_msg "Docker already installed, skipping"
    __process_msg "Docker already initialized, skipping"
  fi
}

install_ecr() {
  skip_step=0
  _check_component_status "ecrInitialized"
  if [ $skip_step -eq 0 ]; then
    __process_msg "Installing Docker on management machine"
    local gitlab_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="swarm")')
    local host=$(echo $gitlab_host | jq '.ip')
    _copy_script_remote $host "installEcr.sh" "$SCRIPT_DIR_REMOTE"
    _exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/installEcr.sh"
    _update_install_status "ecrInstalled"
    _update_install_status "ecrInitialized"
  else
    __process_msg "ECR already installed, skipping"
    __process_msg "ECR already initialized, skipping"
  fi
}

install_swarm() {
  skip_step=0
  _check_component_status "swarmInstalled"
  if [ $skip_step -eq 0 ]; then
    __process_msg "Installing Swarm"
    local gitlab_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="swarm")')
    local host=$(echo $gitlab_host | jq '.ip')
    _copy_script_remote $host "installSwarm.sh" "$SCRIPT_DIR_REMOTE"
    _exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/installSwarm.sh"

    __process_msg "Initializing docker swarm master"
    _exec_remote_cmd "$host" "docker swarm leave --force || true"
    local swarm_init_cmd="docker swarm init --advertise-addr $host"
    _exec_remote_cmd "$host" "$swarm_init_cmd"

    local swarm_worker_token="swarm_worker_token.txt"
    local swarm_worker_token_remote="$SCRIPT_DIR_REMOTE/$swarm_worker_token"
    _exec_remote_cmd "$host" "'docker swarm join-token -q worker > $swarm_worker_token_remote'"
    _copy_script_local $host "$swarm_worker_token_remote"

    local script_dir_local="/tmp/shippable"
    local swarm_worker_token_local="$script_dir_local/$swarm_worker_token"
    local swarm_worker_token=$(cat $swarm_worker_token_local)

    local swarm_worker_token_update=$(cat $STATE_FILE | jq '
      .systemSettings.swarmWorkerToken = "'$swarm_worker_token'"')
    update=$(echo $swarm_worker_token_update | jq '.' | tee $STATE_FILE)

    __process_msg "Running Swarm in drain mode"
    local swarm_master_host_name="swarm_master_host_name.txt"
    local swarm_master_host_name_remote="$SCRIPT_DIR_REMOTE/$swarm_master_host_name"
    _exec_remote_cmd "$host" "'docker node inspect self | jq -r '.[0].Description.Hostname' > $swarm_master_host_name_remote'"
    _copy_script_local $host "$swarm_master_host_name_remote"

    local swarm_master_host_name_remote="$script_dir_local/$swarm_master_host_name"
    local swarm_master_host_name=$(cat $swarm_master_host_name_remote)
    _exec_remote_cmd "$host" "docker node update  --availability drain $swarm_master_host_name"

    _update_install_status "swarmInstalled"
  else
    __process_msg "Swarm already installed, skipping"
  fi
 }

initialize_workers() {
  skip_step=0
  _check_component_status "swarmInitialized"
  if [ $skip_step -eq 0 ]; then
    __process_msg "Initializing swarm workers on service machines"
    local gitlab_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="swarm")')
    local gitlab_host_ip=$(echo $gitlab_host | jq -r '.ip')

    local service_machines_list=$(cat $STATE_FILE | jq '[ .machines[] | select(.group=="services") ]')
    local service_machines_count=$(echo $service_machines_list | jq '. | length')
    for i in $(seq 1 $service_machines_count); do
      local machine=$(echo $service_machines_list | jq '.['"$i-1"']')
      local host=$(echo $machine | jq '.ip')
      local swarm_worker_token=$(cat $STATE_FILE | jq '.systemSettings.swarmWorkerToken')
      _exec_remote_cmd "$host" "docker swarm leave || true"
      _exec_remote_cmd "$host" "docker swarm join --token $swarm_worker_token $gitlab_host_ip"
    done
    _update_install_status "swarmInitialized"
  else
    __process_msg "Swarm already initialized, skipping"
  fi
}

install_redis() {
  skip_step=0
  _check_component_status "redisInitialized"
  local redis_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="db")')
  local host=$(echo $redis_host | jq '.ip')

  if [ $skip_step -eq 0 ]; then
    __process_msg "Installing Redis"
    _copy_script_remote $host "redis.conf" "/etc/redis"
    _copy_script_remote $host "installRedis.sh" "$SCRIPT_DIR_REMOTE"
    _exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/installRedis.sh"
    _update_install_status "redisInstalled"
    _update_install_status "redisInitialized"
  else
    __process_msg "Redis already installed, skipping"
    __process_msg "Redis already initialized, skipping"
  fi

  local ip=$(echo $redis_host | jq -r '.ip')
  local redis_url="$ip:6379"
  #TODO : Fetch the redis port from the redis.conf
  result=$(cat $STATE_FILE | jq -r '.systemSettings.redisUrl = "'$redis_url'"')
  update=$(echo $result | jq '.' | tee $STATE_FILE)
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

main() {
  __process_marker "Installing core"
  validate_core_config
  install_database
  save_db_credentials_in_statefile
  save_db_credentials
  install_vault
  save_vault_credentials
  install_rabbitmq
  save_gitlab_state
  install_gitlab
  install_docker
  install_ecr
  install_swarm
  initialize_workers
  install_redis
  install_rp
}

main
