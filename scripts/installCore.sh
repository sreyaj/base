readonly CORE_COMPONENTS="postgresql \
  vault \
  gitlab \
  swarm \
  rabbitmq"

###########################################################
export CORE_COMPONENTS_LIST=""
export CORE_MACHINES_LIST=""
export SKIP_STEP=false

_update_install_status() {
  local update=$(cat $STATE_FILE | jq '.installStatus.'"$1"'='true'')
  _update_state "$update"
}

_check_component_status() {
  local status=$(cat $STATE_FILE | jq '.installStatus.'"$1"'')
  if [ "$status" == true ]; then
    SKIP_STEP=true;
  fi
}

install_docker() {
  SKIP_STEP=false
  _check_component_status "dockerInitialized"
  if [ "$SKIP_STEP" == false ]; then
    __process_msg "Installing Docker on management machine"
    local gitlab_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="swarm")')
    local host=$(echo $gitlab_host | jq '.ip')
    _copy_script_remote $host "$REMOTE_SCRIPTS_DIR/installDocker.sh" "$SCRIPT_DIR_REMOTE"
    _exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/installDocker.sh"

    __process_msg "Installing Docker on service machines"
    local service_machines_list=$(cat $STATE_FILE | jq '[ .machines[] | select(.group=="services") ]')
    local service_machines_count=$(echo $service_machines_list | jq '. | length')
    for i in $(seq 1 $service_machines_count); do
      local machine=$(echo $service_machines_list | jq '.['"$i-1"']')
      local host=$(echo $machine | jq '.ip')
      _copy_script_remote $host "$REMOTE_SCRIPTS_DIR/installDocker.sh" "$SCRIPT_DIR_REMOTE"
      _exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/installDocker.sh"
    done
    __process_msg "Please configure http_proxy in /etc/default/docker, if proxy needs to be configured. Press any button to continue, once this is done..."
    read response
    _update_install_status "dockerInstalled"
    _update_install_status "dockerInitialized"
  else
    __process_msg "Docker already installed, skipping"
    __process_msg "Docker already initialized, skipping"
  fi
}

install_docker_local() {
  SKIP_STEP=false
  _check_component_status "dockerInitialized"
  if [ "$SKIP_STEP" == false ]; then
    __process_msg "Installing Docker on localhost"
    source "$REMOTE_SCRIPTS_DIR/installDocker.sh" "$INSTALL_MODE"

    _update_install_status "dockerInstalled"
    _update_install_status "dockerInitialized"
  else
    __process_msg "Docker already installed, skipping"
    __process_msg "Docker already initialized, skipping"
  fi
}

install_swarm() {
  SKIP_STEP=false
  _check_component_status "swarmInstalled"
  if [ "$SKIP_STEP" = false ]; then
    __process_msg "Installing Swarm"
    local gitlab_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="swarm")')
    local host=$(echo $gitlab_host | jq '.ip')
    _copy_script_remote $host "$REMOTE_SCRIPTS_DIR/installSwarm.sh" "$SCRIPT_DIR_REMOTE"
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

install_swarm_local() {
  SKIP_STEP=false
  _check_component_status "swarmInstalled"
  if [ "$SKIP_STEP" == false ]; then
    __process_msg "Installing Swarm on localhost"
    source "$REMOTE_SCRIPTS_DIR/installSwarm.sh" "$INSTALL_MODE"
    _update_install_status "swarmInstalled"
  else
    __process_msg "Swarm already installed, skipping"
  fi

  SKIP_STEP=false
  _check_component_status "swarmInitialized"
  if [ "$SKIP_STEP" == false ]; then
    __process_msg "Initializing docker swarm"
    sudo docker swarm leave --force || true
    docker swarm init --advertise-addr 127.0.0.1
    _update_install_status "swarmInitialized"
  else
    __process_msg "Swarm already initialized, skipping"
  fi
}

install_compose(){
  SKIP_STEP=false
  _check_component_status "composeInstalled"
  if [ "$SKIP_STEP" == false ]; then
    if ! type "docker-compose" > /dev/null; then
      echo "Downloading docker compose"
      local download_compose_exc=$(wget https://github.com/docker/compose/releases/download/1.8.1/docker-compose-`uname -s`-`uname -m` -O /tmp/docker-compose)
      echo "$download_compose_exc"

      sudo chmod +x /tmp/docker-compose
      local extract_compose_exc=$(sudo mv /tmp/docker-compose /usr/local/bin/)
      echo "$extract_compose_exc"

      sudo docker-compose --version
    fi
    _update_install_status "composeInstalled"
  else
    __process_msg "Docker compose already, installed, skipping"
    sudo docker-compose --version
  fi
}

install_database() {
  SKIP_STEP=false
  _check_component_status "databaseInitialized"
  if [ "$SKIP_STEP" = false ]; then
    __process_msg "Installing Database"
    local db_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="db")')
    local host=$(echo $db_host | jq '.ip')
    ##TODO:
    # - prommt user for db username and password
    # - copy the installation script to remote machine
    # - run sed command to replace username/password with user input
    # - once complete, save the values in satefile
    _copy_script_remote $host "$REMOTE_SCRIPTS_DIR/installPostgresql.sh" "$SCRIPT_DIR_REMOTE"
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

install_database_local() {
  SKIP_STEP=false
  _check_component_status "databaseInstalled"

  if [ "$SKIP_STEP" = false ]; then
    __process_msg "Installing Database"

    sudo docker-compose -f $LOCAL_SCRIPTS_DIR/services.yml up -d postgres
    __process_msg "Waiting 30s for postgres to boot"
    sleep 30s

    _update_install_status "databaseInstalled"
  else
    __process_msg "Database already installed, skipping"
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

save_db_credentials_in_statefile_local() {
  __process_msg "Saving database credentials in state file local"
  local db_ip=172.17.42.1
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

initialize_database_local() {
  SKIP_STEP=false
  _check_component_status "databaseInitialized"

  if [ "$SKIP_STEP" = false ]; then
    __process_msg "Initializing Database"
    local db_ip=172.17.42.1
    local db_port=5432
    local db_username=$(cat $STATE_FILE | jq -r '.systemSettings.dbUsername')
    local db_name=$(cat $STATE_FILE | jq -r '.systemSettings.dbname')

    local vault_migrations_file="$REMOTE_SCRIPTS_DIR/vault_kv_store.sql"
    local db_mount_dir="$LOCAL_SCRIPTS_DIR/data"

    sudo cp -vr $vault_migrations_file $db_mount_dir
    sudo docker exec local_postgres_1 psql -U $db_username -d $db_name -f /tmp/data/vault_kv_store.sql

    _update_install_status "databaseInitialized"
  else
    __process_msg "Database already initialized, skipping"
  fi
}

save_db_credentials() {
  __process_msg "Saving database credentials"
  local db_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="db")')
  local host=$(echo $db_host | jq '.ip')
  local db_ip=$(echo $db_host | jq '.ip')
  local db_port=5432
  local db_username=$(cat $STATE_FILE | jq -r '.systemSettings.dbUsername')
  local db_password=$(cat $STATE_FILE | jq -r '.systemSettings.dbPassword')
  local db_address=$db_ip:$db_port

  #TODO: fetch db_name from state.json
  # make substitutions locally and then push
  local db_name="shipdb"

  _copy_script_remote $host "$REMOTE_SCRIPTS_DIR/.pgpass" "/root/"
  _exec_remote_cmd $host "sed -i \"s/{{address}}/$db_address/g\" /root/.pgpass"
  _exec_remote_cmd $host "sed -i \"s/{{database}}/$db_name/g\" /root/.pgpass"
  _exec_remote_cmd $host "sed -i \"s/{{username}}/$db_username/g\" /root/.pgpass"
  _exec_remote_cmd $host "sed -i \"s/{{password}}/$db_password/g\" /root/.pgpass"
  _exec_remote_cmd $host "chmod 0600 /root/.pgpass"
}

install_vault() {
  local vault_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="db")')
  local host=$(echo $vault_host | jq '.ip')

  SKIP_STEP=false
  _check_component_status "vaultInstalled"
  if [ "$SKIP_STEP" = false ]; then
    __process_msg "Installing Vault"
    _copy_script_remote $host "$REMOTE_SCRIPTS_DIR/installVault.sh" "$SCRIPT_DIR_REMOTE"
    _exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/installVault.sh"
    _update_install_status "vaultInstalled"
  else
    __process_msg "Vault already installed, skipping"
  fi

  SKIP_STEP=false
  _check_component_status "vaultInitialized"
  if [ "$SKIP_STEP" = false ]; then
    local vault_url=$host

    local db_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="db")')
    local db_ip=$(echo $db_host | jq '.ip')
    local db_port=5432
    local db_username=$(cat $STATE_FILE | jq '.systemSettings.dbUsername')
    local db_address=$db_ip:$db_port

    local db_name="shipdb"
    local VAULT_JSON_FILE="/etc/vault.d/vaultConfig.json"

    _copy_script_remote $host "$REMOTE_SCRIPTS_DIR/vault.hcl" "/etc/vault.d/"
    _copy_script_remote $host "$REMOTE_SCRIPTS_DIR/policy.hcl" "/etc/vault.d/"
    _copy_script_remote $host "$REMOTE_SCRIPTS_DIR/vault_kv_store.sql" "/etc/vault.d/"
    _copy_script_remote $host "$REMOTE_SCRIPTS_DIR/vault.conf" "/etc/init/"
    _copy_script_remote $host "$REMOTE_SCRIPTS_DIR/vaultConfig.json" "/etc/vault.d/"

    _exec_remote_cmd $host "sed -i \"s/{{DB_USERNAME}}/$db_username/g\" /etc/vault.d/vault.hcl"
    _exec_remote_cmd $host "sed -i \"s/{{DB_PASSWORD}}/$db_password/g\" /etc/vault.d/vault.hcl"
    _exec_remote_cmd $host "sed -i \"s/{{DB_ADDRESS}}/$db_address/g\" /etc/vault.d/vault.hcl"

    _exec_remote_cmd $host "psql -U $db_username -h $db_ip -d $db_name -w -f /etc/vault.d/vault_kv_store.sql"

    _exec_remote_cmd $host "service vault start || true"

    _copy_script_remote $host "$REMOTE_SCRIPTS_DIR/bootstrapVault.sh" "$SCRIPT_DIR_REMOTE"
    _exec_remote_cmd_proxyless "$host" "$SCRIPT_DIR_REMOTE/bootstrapVault.sh $db_username $db_name $db_ip $vault_url"
    _update_install_status "vaultInitialized"
  else
    __process_msg "Vault already initialized, skipping"
  fi
}

install_vault_local() {
  SKIP_STEP=false
  _check_component_status "vaultInstalled"
  if [ "$SKIP_STEP" = false ]; then
    __process_msg "Installing Vault"

    sudo docker-compose -f $LOCAL_SCRIPTS_DIR/services.yml up -d vault

    __process_msg "Waiting 10s for vault to boot"
    sleep 10s

    _update_install_status "vaultInstalled"
  else
    __process_msg "Vault already installed, skipping"
  fi
}

initialize_vault_local() {
  SKIP_STEP=false
  _check_component_status "vaultInitialized"
  if [ "$SKIP_STEP" = false ]; then
    __process_msg "Initializing Vault"
    docker exec -it local_vault_1 sh -c '/vault/config/scripts/bootstrap.sh'
    local vault_config_dir="$LOCAL_SCRIPTS_DIR/vault"
    local vault_token_file="$vault_config_dir/scripts/vaultToken.json"
    local vault_token=$(cat "$vault_token_file" | jq -r '.vaultToken')
    __process_msg "Generated vault token $vault_token"


    result=$(cat $STATE_FILE | jq -r '.systemSettings.vaultToken = "'$vault_token'"')
    update=$(echo $result | jq '.' | tee $STATE_FILE)

    local vault_url="http://172.17.42.1:8200"
    result=$(cat $STATE_FILE | jq -r '.systemSettings.vaultUrl = "'$vault_url'"')
    update=$(echo $result | jq '.' | tee $STATE_FILE)

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
  local amqp_host=$(echo $db_host | jq -r '.ip')
  local amqp_port=$(cat $STATE_FILE | jq -r '.systemSettings.amqpPort')
  local amqp_admin_port=$(cat $STATE_FILE | jq -r '.systemSettings.amqpAdminPort')
  local amqp_protocol=$(cat $STATE_FILE | jq -r '.systemSettings.amqpProtocol')
  local amqp_admin_protocol=$(cat $STATE_FILE | jq -r '.systemSettings.amqpAdminProtocol')

  SKIP_STEP=false
  _check_component_status "rabbitmqInstalled"
  if [ "$SKIP_STEP" = false ]; then
    __process_msg "Installing RabbitMQ"
    _copy_script_remote $host "$REMOTE_SCRIPTS_DIR/installRabbit.sh" "$SCRIPT_DIR_REMOTE"
    _exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/installRabbit.sh"
    _update_install_status "rabbitmqInstalled"
  else
    amqp_host=$(cat $STATE_FILE \
      | jq '.systemSettings.amqpHost')
    amqp_port=$(cat $STATE_FILE \
      | jq '.systemSettings.amqpPort')
    amqp_admin_port=$(cat $STATE_FILE \
      | jq '.systemSettings.amqpAdminPort')
    amqp_protocol=$(cat $STATE_FILE \
      | jq '.systemSettings.amqpProtocol')
    amqp_admin_protocol=$(cat $STATE_FILE \
      | jq '.systemSettings.amqpAdminProtocol')

    __process_msg "RabbitMQ already installed, skipping"
  fi

  _copy_script_remote $host "$REMOTE_SCRIPTS_DIR/rabbitmqadmin" "$SCRIPT_DIR_REMOTE"

  # TODO: The user should be prompted to enter a username and password, which should be
  # used by the bootstrapRabbit.sh
  SKIP_STEP=false
  _check_component_status "rabbitmqInitialized"
  if [ "$SKIP_STEP" = false ]; then
    _copy_script_remote $host "$REMOTE_SCRIPTS_DIR/bootstrapRabbit.sh" "$SCRIPT_DIR_REMOTE"
    _exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/bootstrapRabbit.sh"
    _update_install_status "rabbitmqInitialized"
  else
    __process_msg "RabbitMQ already initialized, skipping"
  fi

  local amqp_user="SHIPPABLETESTUSER"
  local amqp_pass="SHIPPABLETESTPASS"
  local amqp_exchange="shippableEx"

  local amqp_url="$amqp_protocol://$amqp_user:$amqp_pass@$amqp_host:$amqp_port/shippable"
  __process_msg "Amqp url: $amqp_url"
  local update=$(cat $STATE_FILE | jq '.systemSettings.amqpUrl = "'$amqp_url'"')
  update=$(echo $update | jq '.' | tee $STATE_FILE)

  local amqp_url_root="$amqp_protocol://$amqp_user:$amqp_pass@$amqp_host:$amqp_port/shippableRoot"
  __process_msg "Amqp root url: $amqp_url_root"
  update=$(cat $STATE_FILE | jq '.systemSettings.amqpUrlRoot = "'$amqp_url_root'"')
  update=$(echo $update | jq '.' | tee $STATE_FILE)

  local amqp_url_admin="$amqp_admin_protocol://$amqp_user:$amqp_pass@$amqp_host:$amqp_admin_port"
  __process_msg "Amqp admin url: $amqp_url_admin"
  update=$(cat $STATE_FILE | jq '.systemSettings.amqpUrlAdmin = "'$amqp_url_admin'"')
  update=$(echo $update | jq '.' | tee $STATE_FILE)

  update=$(cat $STATE_FILE | jq '.systemSettings.amqpDefaultExchange = "'$amqp_exchange'"')
  update=$(echo $update | jq '.' | tee $STATE_FILE)
}

install_rabbitmq_local() {
  SKIP_STEP=false
  _check_component_status "rabbitmqInstalled"
  if [ "$SKIP_STEP" = false ]; then
    __process_msg "Installing rabbitmq"

    sudo docker-compose -f $LOCAL_SCRIPTS_DIR/services.yml up -d message

    __process_msg "rabbitmq successfully installed"
    __process_msg "Waiting 10s for rabbitmq to boot"
    sleep 10s
    _update_install_status "rabbitmqInstalled"
  else
    __process_msg "rabbitmq already installed, skipping"
  fi
}

initialize_rabbitmq_local() {
  SKIP_STEP=false
  _check_component_status "rabbitmqInitialized"
  if [ "$SKIP_STEP" = false ]; then

    source "$LOCAL_SCRIPTS_DIR/bootstrapRabbit.sh"
    __process_msg "rabbitmq successfully initialized"

    _update_install_status "rabbitmqInitialized"
  else
    __process_msg "RabbitMQ already initialized, skipping"
  fi
}

save_gitlab_state() {
  local gitlab_sys_int=$(cat $STATE_FILE | jq '.systemIntegrations[] | select(.name=="gitlab")')
  if [ -z "$gitlab_sys_int" ]; then
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
  fi
}

install_gitlab() {
  SKIP_STEP=false
  _check_component_status "gitlabInitialized"
  if [ "$SKIP_STEP" = false ]; then
    __process_msg "Installing Gitlab"
    local gitlab_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="swarm")')
    local host=$(echo $gitlab_host | jq -r '.ip')
    local gitlab_system_int=$(cat $STATE_FILE | jq '.systemIntegrations[] | select (.name=="gitlab")')

    local gitlab_root_password=$(echo $gitlab_system_int | jq -r '.formJSONValues[]| select (.label=="password")|.value')
    local gitlab_external_url=$(echo $gitlab_system_int | jq -r '.formJSONValues[]| select (.label=="url")|.value')

    _copy_script_remote $host "$REMOTE_SCRIPTS_DIR/installGitlab.sh" "$SCRIPT_DIR_REMOTE"
    _copy_script_remote $host "$REMOTE_SCRIPTS_DIR/gitlab.rb" "/etc/gitlab/"

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

install_gitlab_local() {
  SKIP_STEP=false
  _check_component_status "gitlabInstalled"
  if [ "$SKIP_STEP" = false ]; then
    __process_msg "Installing Gitlab"

    sudo docker-compose -f $LOCAL_SCRIPTS_DIR/services.yml up -d gitlab

    _update_install_status "gitlabInstalled"
  else
    __process_msg "Gitlab already installed, skipping"
  fi
}

install_ecr() {
  SKIP_STEP=false
  _check_component_status "ecrInitialized"
  if [ "$SKIP_STEP" = false ]; then
    __process_msg "Installing Docker on management machine"
    local gitlab_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="swarm")')
    local host=$(echo $gitlab_host | jq '.ip')
    _copy_script_remote $host "$REMOTE_SCRIPTS_DIR/installEcr.sh" "$SCRIPT_DIR_REMOTE"
    _exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/installEcr.sh"
    _update_install_status "ecrInstalled"
    _update_install_status "ecrInitialized"
  else
    __process_msg "ECR already installed, skipping"
    __process_msg "ECR already initialized, skipping"
  fi
}

install_ecr_local() {
  SKIP_STEP=false
  _check_component_status "ecrInitialized"
  if [ "$SKIP_STEP" = false ]; then
    __process_msg "Installing ECR on local machine"

    sudo apt-get -y install python-pip
    sudo pip install awscli==1.10.63

    _update_install_status "ecrInstalled"
    _update_install_status "ecrInitialized"
  else
    __process_msg "ECR already installed, skipping"
    __process_msg "ECR already initialized, skipping"
  fi
}

initialize_workers() {
  SKIP_STEP=false
  _check_component_status "swarmInitialized"
  if [ "$SKIP_STEP" = false ]; then
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
  SKIP_STEP=false
  _check_component_status "redisInitialized"
  local redis_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="db")')
  local host=$(echo $redis_host | jq '.ip')

  if [ "$SKIP_STEP" = false ]; then
    __process_msg "Installing Redis"
    _copy_script_remote $host "$REMOTE_SCRIPTS_DIR/redis.conf" "/etc/redis"
    _copy_script_remote $host "$REMOTE_SCRIPTS_DIR/installRedis.sh" "$SCRIPT_DIR_REMOTE"
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

install_redis_local() {
  SKIP_STEP=false
  _check_component_status "redisInstalled"

  if [ "$SKIP_STEP" = false ]; then
    __process_msg "Installing Redis"

    sudo docker-compose -f $LOCAL_SCRIPTS_DIR/services.yml up -d redis

    local redis_url="172.17.42.1:6379"
    result=$(cat $STATE_FILE | jq -r '.systemSettings.redisUrl = "'$redis_url'"')
    update=$(echo $result | jq '.' | tee $STATE_FILE)

    __process_msg "Redis successfully intalled"
    _update_install_status "redisInstalled"
  else
    __process_msg "Redis already installed, skipping"
  fi
}

main() {
  __process_marker "Installing core"
  if [ "$INSTALL_MODE" == "production" ]; then
    install_docker
    install_swarm
    install_database
    save_db_credentials_in_statefile
    save_db_credentials
    install_vault
    save_vault_credentials
    install_rabbitmq
    save_gitlab_state
    install_gitlab
    install_ecr
    initialize_workers
    install_redis
  else
    install_docker_local
    install_swarm_local
    install_compose
    install_database_local
    save_db_credentials_in_statefile_local
    initialize_database_local
    install_vault_local
    initialize_vault_local
    install_rabbitmq_local
    initialize_rabbitmq_local
    install_gitlab_local
    install_ecr_local
    install_redis_local
  fi
}

main
