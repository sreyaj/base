#!/bin/bash -e

export SKIP_STEP=false
export sleep_time=1
export time_taken=0

_update_install_status() {
  local update=$(cat $STATE_FILE | jq '.installStatus.'"$1"'='true'')
  _update_state "$update"
}

_check_component_status() {
  local status=$(cat $STATE_FILE | jq '.installStatus.'"$1"'')
  if [ "$status" = true ]; then
    SKIP_STEP=true;
  fi
}

generate_serviceuser_token() {
  SKIP_STEP=false
  _check_component_status "serviceuserTokenGenerated"
  if [ "$SKIP_STEP" = false ]; then
    __process_msg "Generating random token for serviceuser"
    local token=$(cat /proc/sys/kernel/random/uuid)
    local stateToken=$(cat $STATE_FILE | jq '.systemSettings.serviceUserToken="'$token'"')
    echo $stateToken > $STATE_FILE
    _update_install_status "serviceuserTokenGenerated"
  else
    __process_msg "Service user token already generated, skipping"
  fi
}

update_system_node_keys() {
  local private_key=""
  while read line; do
    private_key=$private_key""$line"\n"
  done <$SSH_PRIVATE_KEY
  local public_key=""
  while read line; do
    public_key=$public_key""$line"\n"
  done <$SSH_PUBLIC_KEY
  local update=$(cat $STATE_FILE | jq '.systemSettings.systemNodePublicKey="'$public_key'"')
  _update_state "$update"
  local update=$(cat $STATE_FILE | jq '.systemSettings.systemNodePrivateKey="'$private_key'"')
  _update_state "$update"
}

generate_system_config() {
  __process_msg "Inserting data into systemConfigs Table"

  #TODO: put sed update into a function and call it for each variable
  local system_configs_template="$USR_DIR/system_configs.sql.template"
  local system_configs_sql="$USR_DIR/system_configs.sql"

  # NOTE:
  # "sed" is using '#' as a separator in following statements
  __process_msg "Updating : defaultMinionCount"
  local default_minion_count=$(cat $STATE_FILE | jq -r '.systemSettings.defaultMinionCount')
  sed "s#{{DEFAULT_MINION_COUNT}}#$default_minion_count#g" $system_configs_template > $system_configs_sql

  __process_msg "Updating : defaultPipelineCount"
  local default_pipeline_count=$(cat $STATE_FILE | jq -r '.systemSettings.defaultPipelineCount')
  sed -i "s#{{DEFAULT_PIPELINE_COUNT}}#$default_pipeline_count#g" $system_configs_sql

  __process_msg "Updating : serverEnabled"
  local server_enabled=$(cat $STATE_FILE | jq -r '.systemSettings.serverEnabled')
  sed -i "s#{{SERVER_ENABLED}}#$server_enabled#g" $system_configs_sql

 __process_msg "Updating : autoSelectBuilderToken"
  local auto_select_builder_token=$(cat $STATE_FILE | jq -r '.systemSettings.autoSelectBuilderToken')
  sed -i "s#{{AUTO_SELECT_BUILDER_TOKEN}}#$auto_select_builder_token#g" $system_configs_sql

  __process_msg "Updating : buildTimeout"
  local build_timeout=$(cat $STATE_FILE | jq -r '.systemSettings.buildTimeoutMS')
  sed -i "s#{{BUILD_TIMEOUT_MS}}#$build_timeout#g" $system_configs_sql

  __process_msg "Updating : defaultPrivateJobQuota"
  local private_job_quota=$(cat $STATE_FILE | jq -r '.systemSettings.defaultPrivateJobQuota')
  sed -i "s#{{DEFAULT_PRIVATE_JOB_QUOTA}}#$private_job_quota#g" $system_configs_sql

  __process_msg "Updating : serviceuserToken"
  local serviceuser_token=$(cat $STATE_FILE | jq -r '.systemSettings.serviceUserToken')
  sed -i "s#{{SERVICE_USER_TOKEN}}#$serviceuser_token#g" $system_configs_sql

  __process_msg "Updating : vaultUrl"
  local vault_url=$(cat $STATE_FILE | jq -r '.systemSettings.vaultUrl')
  sed -i "s#{{VAULT_URL}}#$vault_url#g" $system_configs_sql

  __process_msg "Updating : vaultToken"
  local vault_token=$(cat $STATE_FILE | jq -r '.systemSettings.vaultToken')
  sed -i "s#{{VAULT_TOKEN}}#$vault_token#g" $system_configs_sql

  __process_msg "Updating : vaultRefreshTime"
  local vault_refresh_time=$(cat $STATE_FILE | jq -r '.systemSettings.vaultRefreshTimeInSec')
  sed -i "s#{{VAULT_REFRESH_TIME_SEC}}#$vault_refresh_time#g" $system_configs_sql

  __process_msg "Updating : amqpUrl"
  local amqp_url=$(cat $STATE_FILE | jq -r '.systemSettings.amqpUrl')
  sed -i "s#{{AMQP_URL}}#$amqp_url#g" $system_configs_sql

  __process_msg "Updating : amqpUrlAdmin"
  local amqp_url_admin=$(cat $STATE_FILE | jq -r '.systemSettings.amqpUrlAdmin')
  sed -i "s#{{AMQP_URL_ADMIN}}#$amqp_url_admin#g" $system_configs_sql

  __process_msg "Updating : amqpUrlRoot"
  local amqp_url_root=$(cat $STATE_FILE | jq -r '.systemSettings.amqpUrlRoot')
  sed -i "s#{{AMQP_URL_ROOT}}#$amqp_url_root#g" $system_configs_sql

  __process_msg "Updating : amqpDefaultExchange"
  local amqp_default_exchange=$(cat $STATE_FILE | jq -r '.systemSettings.amqpDefaultExchange')
  sed -i "s#{{AMQP_DEFAULT_EXCHANGE}}#$amqp_default_exchange#g" $system_configs_sql

  __process_msg "Updating : apiUrl"
  local api_url=$(cat $STATE_FILE | jq -r '.systemSettings.apiUrl')
  sed -i "s#{{API_URL}}#$api_url#g" $system_configs_sql

  __process_msg "Updating : apiPort"
  local api_port=$(cat $STATE_FILE | jq -r '.systemSettings.apiPort')
  sed -i "s#{{API_PORT}}#$api_port#g" $system_configs_sql

  __process_msg "Updating : wwwUrl"
  local www_url=$(cat $STATE_FILE | jq -r '.systemSettings.wwwUrl')
  sed -i "s#{{WWW_URL}}#$www_url#g" $system_configs_sql

  __process_msg "Updating : runMode"
  local run_mode=$(cat $STATE_FILE | jq -r '.systemSettings.runMode')
  sed -i "s#{{RUN_MODE}}#$run_mode#g" $system_configs_sql

  __process_msg "Updating : rootQueueList"
  local root_queue_list=$(cat $STATE_FILE | jq -r '.systemSettings.rootQueueList')
  sed -i "s#{{ROOT_QUEUE_LIST}}#$root_queue_list#g" $system_configs_sql

  __process_msg "Updating : execImage"
  local exec_image=$(cat $STATE_FILE | jq -r '.systemSettings.execImage')
  sed -i "s#{{EXEC_IMAGE}}#$exec_image#g" $system_configs_sql

  __process_msg "Updating : createdAt"
  local created_at=$(date)
  sed -i "s#{{CREATED_AT}}#$created_at#g" $system_configs_sql

  __process_msg "Updating : updatedAt"
  sed -i "s#{{UPDATED_AT}}#$created_at#g" $system_configs_sql

  __process_msg "Updating : dynamicNodesSystemIntegrationId"
  local dynamic_nodes_system_integration_id=$(cat $STATE_FILE | jq -r '.systemSettings.dynamicNodesSystemIntegrationId')
  sed -i "s#{{DYNAMIC_NODES_SYSTEM_INTEGRATION_ID}}#$dynamic_nodes_system_integration_id#g" $system_configs_sql

  __process_msg "Updating : systemNodePrivateKey"
  local system_node_private_key=$(cat $STATE_FILE | jq '.systemSettings.systemNodePrivateKey' | sed s/\"//g)
  sed -i "s#{{SYSTEM_NODE_PRIVATE_KEY}}#$system_node_private_key#g" $system_configs_sql

  __process_msg "Updating : systemNodePublicKey"
  local system_node_public_key=$(cat $STATE_FILE | jq -r '.systemSettings.systemNodePublicKey')
  sed -i "s#{{SYSTEM_NODE_PUBLIC_KEY}}#$system_node_public_key#g" $system_configs_sql

  __process_msg "Updating : allowSystemNodes"
  local allow_system_nodes=$(cat $STATE_FILE | jq -r '.systemSettings.allowSystemNodes')
  sed -i "s#{{ALLOW_SYSTEM_NODES}}#$allow_system_nodes#g" $system_configs_sql

  __process_msg "Updating : allowDynamicNodes"
  local allow_dynamic_nodes=$(cat $STATE_FILE | jq -r '.systemSettings.allowDynamicNodes')
  sed -i "s#{{ALLOW_DYNAMIC_NODES}}#$allow_dynamic_nodes#g" $system_configs_sql

  __process_msg "Updating : allowCustomNodes"
  local allow_custom_nodes=$(cat $STATE_FILE | jq -r '.systemSettings.allowCustomNodes')
  sed -i "s#{{ALLOW_CUSTOM_NODES}}#$allow_custom_nodes#g" $system_configs_sql

  __process_msg "Updating : consoleMaxLifespan"
  local console_max_lifespan=$(cat $STATE_FILE | jq -r '.systemSettings.consoleMaxLifespan')
  sed -i "s#{{CONSOLE_MAX_LIFESPAN}}#$console_max_lifespan#g" $system_configs_sql

  __process_msg "Updating : consoleCleanupHour"
  local console_cleanup_hour=$(cat $STATE_FILE | jq -r '.systemSettings.consoleCleanupHour')
  sed -i "s#{{CONSOLE_CLEANUP_HOUR}}#$console_cleanup_hour#g" $system_configs_sql

  __process_msg "Updating : customHostDockerVersion"
  local custom_host_docker_version=$(cat $STATE_FILE | jq -r '.systemSettings.customHostDockerVersion')
  sed -i "s#{{CUSTOM_HOST_DOCKER_VERSION}}#$custom_host_docker_version#g" $system_configs_sql

  __process_msg "Successfully generated 'systemConfig' table data"
}

create_system_config() {
  __process_msg "Creating systemConfigs table"
  local db_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="db")')
  local db_ip=$(echo $db_host | jq -r '.ip')
  local db_username=$(cat $STATE_FILE | jq -r '.systemSettings.dbUsername')

  #TODO: fetch db_name from state.json
  local db_name="shipdb"

  _copy_script_remote $db_ip "$USR_DIR/system_configs.sql" "$SCRIPT_DIR_REMOTE"
  _exec_remote_cmd $db_ip "psql -U $db_username -h $db_ip -d $db_name -f $SCRIPT_DIR_REMOTE/system_configs.sql"
  _update_install_status "systemConfigUpdated"
  __process_msg "Successfully created systemConfigs table"
}

create_system_config_local() {
  __process_msg "Creating systemConfigs table on local db"
  local system_configs_file="$USR_DIR/system_configs.sql"
  local db_mount_dir="$LOCAL_SCRIPTS_DIR/data"

  sudo cp -vr $system_configs_file $db_mount_dir
  sudo docker exec local_postgres_1 psql -U $db_username -d $db_name -f /tmp/data/system_configs.sql

  _update_install_status "systemConfigUpdated"
  __process_msg "Successfully created systemConfigs table on local db"
}

generate_api_config() {
  __process_msg "Generating api config"
  local release_file="$VERSIONS_DIR/$RELEASE_VERSION".json
  local api_service=$(cat $release_file | jq '.serviceConfigs[] | select (.name=="api")')

  if [ -z "$api_service" ]; then
    __process_msg "Incorrect release version, missing api configuration"
    exit 1
  fi

  local system_images_registry=$(cat $STATE_FILE | jq -r '.systemSettings.systemImagesRegistry')
  local api_service_repository=$(echo $api_service | jq -r '.repository')
  local api_service_tag=$(cat $STATE_FILE | jq -r '.deployTag')
  local api_service_image="$system_images_registry/$api_service_repository:$api_service_tag"
  __process_msg "Successfully read from state.json: api.image ($api_service_image)"

  local api_env_vars=$(cat $release_file | jq '.serviceConfigs[] | select (.name=="api") | .envs')
  echo $api_env_vars

  local api_env_vars_count=$(echo $api_env_vars | jq '. | length')
  __process_msg "Successfully read from config.json: api.envs ($api_env_vars_count)"

  __process_msg "Generating api environment variables"

  local api_env_values=""
  for i in $(seq 1 $api_env_vars_count); do
    local env_var=$(echo $api_env_vars | jq -r '.['"$i-1"']')

    if [ "$env_var" == "DBNAME" ]; then
      local db_name=$(cat $STATE_FILE | jq -r '.systemSettings.dbname')
      api_env_values="$api_env_values -e $env_var=$db_name"
    elif [ "$env_var" == "DBUSERNAME" ]; then
      local db_username=$(cat $STATE_FILE | jq -r '.systemSettings.dbUsername')
      api_env_values="$api_env_values -e $env_var=$db_username"
    elif [ "$env_var" == "DBPASSWORD" ]; then
      local db_password=$(cat $STATE_FILE | jq -r '.systemSettings.dbPassword')
      api_env_values="$api_env_values -e $env_var=$db_password"
    elif [ "$env_var" == "DBHOST" ]; then
      local db_host=$(cat $STATE_FILE | jq -r '.systemSettings.dbHost')
      api_env_values="$api_env_values -e $env_var=$db_host"
    elif [ "$env_var" == "DBPORT" ]; then
      local db_port=$(cat $STATE_FILE | jq -r '.systemSettings.dbPort')
      api_env_values="$api_env_values -e $env_var=$db_port"
    elif [ "$env_var" == "DBDIALECT" ]; then
      local db_dialect=$(cat $STATE_FILE | jq -r '.systemSettings.dbDialect')
      api_env_values="$api_env_values -e $env_var=$db_dialect"
    elif [ "$env_var" == "SHIPPABLE_API_URL" ]; then
      local db_dialect=$(cat $STATE_FILE | jq -r '.systemSettings.apiUrl')
      api_env_values="$api_env_values -e $env_var=$db_dialect"
    elif [ "$env_var" == "RUN_MODE" ]; then
      local db_dialect=$(cat $STATE_FILE | jq -r '.systemSettings.runMode')
      api_env_values="$api_env_values -e $env_var=$db_dialect"
    else
      echo "No handler for API env : $env_var, exiting"
      exit 1
    fi
  done

  http_proxy=$(cat $STATE_FILE | jq -r '.systemSettings.httpProxy')
  https_proxy=$(cat $STATE_FILE | jq -r '.systemSettings.httpsProxy')
  no_proxy=$(cat $STATE_FILE | jq -r '.systemSettings.noProxy')

  if [ ! -z $http_proxy ]; then
    api_env_values="$api_env_values -e http_proxy=$http_proxy -e HTTP_PROXY=$http_proxy"
    __process_msg "Successfully updated api http_proxy mapping"
  fi

  if [ ! -z $https_proxy ]; then
    api_env_values="$api_env_values -e https_proxy=$https_proxy -e HTTPS_PROXY=$https_proxy"
    __process_msg "Successfully updated api https_proxy mapping"
  fi

  if [ ! -z $no_proxy ]; then
    api_env_values="$api_env_values -e no_proxy=$no_proxy -e NO_PROXY=$no_proxy"
    __process_msg "Successfully updated api no_proxy mapping"
  fi

  __process_msg "Successfully generated api environment variables : $api_env_values"


  local api_service=$(cat $STATE_FILE |  \
    jq '.services=[
          {
            "name": "api",
            "image": "'$api_service_image'"
          }
        ]')
  update=$(echo $api_service | jq '.' | tee $STATE_FILE)

  local api_state_env=$(cat $STATE_FILE | jq '
    .services  |=
    map(if .name == "api" then
        .env = "'$api_env_values'"
      else
        .
      end
    )'
  )
  update=$(echo $api_state_env | jq '.' | tee $STATE_FILE)
  __process_msg "Successfully generated  api environment variables"

  __process_msg "Generating api port mapping"
  local api_port=$(cat $STATE_FILE | jq -r '.systemSettings.apiPort')
  local api_port_mapping=" --publish $api_port:$api_port/tcp"
  __process_msg "api port mapping : $api_port_mapping"

  local api_port_update=$(cat $STATE_FILE | jq '
    .services  |=
    map(if .name == "api" then
        .port = "'$api_port_mapping'"
      else
        .
      end
    )'
  )
  update=$(echo $api_port_update | jq '.' | tee $STATE_FILE)
  __process_msg "Successfully updated api port mapping"

  __process_msg "Generating api service config"
  local api_service_opts=" --name api --mode global --network ingress --with-registry-auth --endpoint-mode vip"
  __process_msg "api service config : $api_service_opts"

  local api_service_update=$(cat $STATE_FILE | jq '
    .services  |=
    map(
      if .name == "api" then
        .opts = "'$api_service_opts'"
      else
        .
      end
    )'
  )
  update=$(echo $api_service_update | jq '.' | tee $STATE_FILE)
  __process_msg "Successfully generated api service config"
}

provision_api() {
  __process_msg "Provisioning api on swarm cluster"
  local swarm_manager_machine=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="swarm")')
  local swarm_manager_host=$(echo $swarm_manager_machine | jq '.ip')

  local port_mapping=$(cat $STATE_FILE | jq -r '.services[] | select (.name=="api") | .port')
  local env_variables=$(cat $STATE_FILE | jq -r '.services[] | select (.name=="api") | .env')
  local name=$(cat $STATE_FILE | jq -r '.services[] | select (.name=="api") | .name')
  local opts=$(cat $STATE_FILE | jq -r '.services[] | select (.name=="api") | .opts')
  local image=$(cat $STATE_FILE | jq -r '.services[] | select (.name=="api") | .image')

  local boot_api_cmd="docker service create \
    $port_mapping \
    $env_variables \
    $opts $image"

  local rm_api_cmd="docker service rm api || true"

  _exec_remote_cmd "$swarm_manager_host" "$rm_api_cmd"
  __process_msg "waiting 20 seconds for api to shut down "
  sleep 20
  _exec_remote_cmd "$swarm_manager_host" "$boot_api_cmd"

  __process_msg "Successfully provisioned api"
}

provision_api_local() {
  __process_msg "Provisioning api on local machine"

  local port_mapping=$(cat $STATE_FILE | jq -r '.services[] | select (.name=="api") | .port')
  local env_variables=$(cat $STATE_FILE | jq -r '.services[] | select (.name=="api") | .env')
  local name=$(cat $STATE_FILE | jq -r '.services[] | select (.name=="api") | .name')
  local opts=$(cat $STATE_FILE | jq -r '.services[] | select (.name=="api") | .opts')
  local image=$(cat $STATE_FILE | jq -r '.services[] | select (.name=="api") | .image')

  sudo docker rm -f api || true
  local boot_api_cmd="sudo docker run -d \
    $port_mapping \
    $env_variables \
    --net host \
    --name api
    $image"

  local result=$(eval $boot_api_cmd)

  __process_msg "Successfully provisioned api"
}

test_api_endpoint() {
  __process_msg "Testing API endpoint to determine API status"

  local api_url=$(cat $STATE_FILE | jq -r '.systemSettings.apiUrl')
  local api_timeout=$(cat $STATE_FILE | jq -r '.systemSettings.apiTimeout')
  if [ "$api_timeout" == "null" ]; then
    api_timeout=0
  fi
  api_timeout=$((api_timeout * 60))

  if [ $api_timeout -eq 0 ] || [ $time_taken -lt $api_timeout ]; then
    if [ $sleep_time -eq 64 ]; then
      sleep_time=2;
    else
      sleep_time=$(( $sleep_time * 2 ))
    fi
  else
    __process_msg "API timeout exceeded. Unable to connect to API."
    exit
  fi

  api_response=$(curl -s -o /dev/null -w "%{http_code}" $api_url) || true

  if [ "$api_response" == "200" ]; then
    __process_msg "API is up and running proceeding with other steps"
  else
    __process_msg "API not running, retrying in $sleep_time seconds"
    sleep $sleep_time
    time_taken=$((time_taken + sleep_time))
    test_api_endpoint
  fi
}

run_migrations() {
  __process_msg "Running migrations.sql"

  local db_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="db")')
  local db_ip=$(echo $db_host | jq -r '.ip')
  local db_username=$(cat $STATE_FILE | jq -r '.systemSettings.dbUsername')
  local db_name="shipdb"

  local migrations_file_path="$MIGRATIONS_DIR/$RELEASE_VERSION.sql"
  if [ ! -f $migrations_file_path ]; then
    __process_msg "No migrations found for this release, skipping"
  else
    local migrations_file_name=$(basename $migrations_file_path)
    _copy_script_remote $db_ip $migrations_file_path "$SCRIPT_DIR_REMOTE"
    _exec_remote_cmd $db_ip "psql -U $db_username -h $db_ip -d $db_name -f $SCRIPT_DIR_REMOTE/$migrations_file_name"
  fi
}

run_migrations_local() {
  __process_msg "Running migrations.sql"

  local db_username=$(cat $STATE_FILE | jq -r '.systemSettings.dbUsername')
  local db_name="shipdb"

  ##TODO: this should be the latest release file
  ##TODO update the version in state after migration is run
  local migrations_file="$MIGRATIONS_DIR/$RELEASE_VERSION.sql"
  if [ ! -f $migrations_file ]; then
    __process_msg "No migrations found for this release, skipping"
  else
    local db_mount_dir="$LOCAL_SCRIPTS_DIR/data/migrations.sql"
    sudo cp -vr $migrations_file $db_mount_dir
    sudo docker exec local_postgres_1 psql -U $db_username -d $db_name -f /tmp/data/migrations.sql
  fi
}

manage_masterIntegrations() {
  __process_msg "Configuring master integrations"
  source "$SCRIPTS_DIR/_manageMasterIntegrations.sh"
}

manage_systemIntegrations() {
  __process_msg "Configuring master integrations"
  source "$SCRIPTS_DIR/_manageSystemIntegrations.sh"
}

insert_system_machine_image() {
  __process_msg "Inserting system machine images"
  local api_url=""
  local api_token=$(cat $STATE_FILE | jq -r '.systemSettings.serviceUserToken')
  local api_url=$(cat $STATE_FILE | jq -r '.systemSettings.apiUrl')
  local system_machine_image_post_endpoint="$api_url/systemMachineImages"

  local system_machine_images=$(cat $STATE_FILE | jq -r '.systemMachineImages')
  local system_machine_images_length=$(echo $system_machine_images | jq -r '. | length')

  for i in $(seq 1 $system_machine_images_length); do
    local system_machine_image=$(echo $system_machine_images | jq '.['"$i-1"']')
    local system_machine_image_provider=$(echo $system_machine_image | jq -r '.provider')
    local system_machine_image_externalId=$(echo $system_machine_image | jq -r '.externalId')
    local query="?provider="$system_machine_image_provider"&externalId="$system_machine_image_externalId
    local existing_system_machine_image=$(curl \
      -H "Content-Type: application/json" \
      -H "Authorization: apiToken $api_token" \
      -X GET $system_machine_image_post_endpoint$query \
      --silent)

    local existing_system_machine_image_length=$(echo $existing_system_machine_image | jq -r '. | length')

    if [ $existing_system_machine_image_length -eq 0 ]; then
      local post_call_resp_code=$(curl -H "Content-Type: application/json" -H "Authorization: apiToken $api_token" \
        -X POST -d "$system_machine_image" $system_machine_image_post_endpoint \
          --write-out "%{http_code}\n" --silent --output /dev/null)
      if [ "$post_call_resp_code" -gt "299" ]; then
        echo "Error inserting system machine image(status code $post_call_resp_code)"
      else
        echo "Sucessfully inserted system machine image: $system_machine_image_name"
      fi
    else
      local system_machine_image_db=$(echo $existing_system_machine_image | jq '.['"0"']')
      local system_machine_image_db_id=$(echo $system_machine_image_db | jq -r '.id')
      local put_system_machine_image_endpoint=$system_machine_image_post_endpoint"/"$system_machine_image_db_id
      local put_call_resp_code=$(curl -H "Content-Type: application/json" -H "Authorization: apiToken $api_token" \
        -X PUT -d "$system_machine_image" $put_system_machine_image_endpoint \
          --write-out "%{http_code}\n" --silent --output /dev/null)
      if [ "$put_call_resp_code" -gt "299" ]; then
        echo "Error updating system machine image(status code $put_call_resp_code)"
      else
        __process_msg "Sucessfully updated system machine image: $system_machine_image_db_id"
      fi
    fi
  done
  __process_msg "Successfully inserted system machine images"
}

update_dynamic_nodes_integration_id() {
  __process_msg "Updating dynamic node system integartion id"
  local api_url=""
  local api_token=$(cat $STATE_FILE | jq -r '.systemSettings.serviceUserToken')
  local api_url=$(cat $STATE_FILE | jq -r '.systemSettings.apiUrl')
  local system_integration_endpoint="$api_url/systemIntegrations"

  local query="?masterType=cloudproviders&name=AWS-ROOT"
  local system_integrations=$(curl \
    -H "Content-Type: application/json" \
    -H "Authorization: apiToken $api_token" \
    -X GET $system_integration_endpoint$query \
    --silent)

    local system_integrations_length=$(echo $system_integrations | jq -r '. | length')
    if [ $system_integrations_length -gt 0 ]; then
      local system_integration=$(echo $system_integrations | jq '.[0]')
      local system_integration_id=$(echo $system_integration | jq -r '.id')
      local update=$(cat $STATE_FILE | jq '.systemSettings.dynamicNodesSystemIntegrationId="'$system_integration_id'"')
      _update_state "$update"
    else
      __process_msg "No system integration configured for dynamic nodes, skipping"
    fi
  __process_msg "Successfully updated dynamic node system integartion id"
}


restart_api() {
  local swarm_manager_machine=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="swarm")')
  local swarm_manager_host=$(echo $swarm_manager_machine | jq '.ip')

  local port_mapping=$(cat $STATE_FILE | jq -r '.services[] | select (.name=="api") | .port')
  local env_variables=$(cat $STATE_FILE | jq -r '.services[] | select (.name=="api") | .env')
  local name=$(cat $STATE_FILE | jq -r '.services[] | select (.name=="api") | .name')
  local opts=$(cat $STATE_FILE | jq -r '.services[] | select (.name=="api") | .opts')
  local image=$(cat $STATE_FILE | jq -r '.services[] | select (.name=="api") | .image')

  local boot_api_cmd="docker service create \
    $port_mapping \
    $env_variables \
    $opts $image"

  local rm_api_cmd="docker service rm api || true"

  _exec_remote_cmd "$swarm_manager_host" "$rm_api_cmd"

  __process_msg "Waiting 30s before API restart..."
  sleep 30

  _exec_remote_cmd "$swarm_manager_host" "$boot_api_cmd"
}

restart_api_local() {
  local port_mapping=$(cat $STATE_FILE | jq -r '.services[] | select (.name=="api") | .port')
  local env_variables=$(cat $STATE_FILE | jq -r '.services[] | select (.name=="api") | .env')
  local name=$(cat $STATE_FILE | jq -r '.services[] | select (.name=="api") | .name')
  local opts=$(cat $STATE_FILE | jq -r '.services[] | select (.name=="api") | .opts')
  local image=$(cat $STATE_FILE | jq -r '.services[] | select (.name=="api") | .image')

  sudo docker rm -f api || true
  local boot_api_cmd="sudo docker run -d \
      $port_mapping \
      $env_variables \
      --net host \
      --name api
      $image"

  local result=$(eval $boot_api_cmd)
  __process_msg "Waiting 10s before API restart..."
  sleep 10
}

update_service_list() {
  __process_msg "configuring services according to master integrations"
  source "$SCRIPTS_DIR/_manageServices.sh"
}

main() {
  __process_marker "Updating system config"
  generate_serviceuser_token

  if [ "$INSTALL_MODE" == "production" ]; then
    update_system_node_keys
    generate_system_config
    create_system_config
    run_migrations
    generate_api_config
    provision_api
    test_api_endpoint
    run_migrations
    manage_masterIntegrations
    manage_systemIntegrations
    insert_system_machine_image
    update_dynamic_nodes_integration_id
    generate_system_config
    create_system_config
    update_service_list
    restart_api
  else
    update_system_node_keys
    generate_system_config
    create_system_config_local
    generate_api_config
    run_migrations_local
    provision_api_local
    test_api_endpoint
    run_migrations_local
    manage_masterIntegrations
    manage_systemIntegrations
    insert_system_machine_image
    update_dynamic_nodes_integration_id
    generate_system_config
    create_system_config_local
    update_service_list
    restart_api_local
  fi
}

main
