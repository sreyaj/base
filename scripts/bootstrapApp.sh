#!/bin/bash -e

generate_serviceuser_token() {
  __process_msg "Generating random token for serviceuser"
  local token=$(cat /proc/sys/kernel/random/uuid)
  local stateToken=$(cat $STATE_FILE | jq '.systemSettings.serviceUserToken="'$token'"')
  echo $stateToken > $STATE_FILE
}

update_docker_creds() {
  __process_msg "Updating docker credentials to pull shippable images"
  local gitlab_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="swarm")')
  local host=$(echo "$gitlab_host" | jq '.ip')

  local docker_login=$(cat $STATE_FILE | jq '.systemSettings.dockerlogin')
  local docker_pass=$(cat $STATE_FILE | jq '.systemSettings.dockerpass')
  local docker_email=$(cat $STATE_FILE | jq '.systemSettings.dockeremail')

  local docker_login_cmd="sudo docker login -u $docker_login -p $docker_pass -e $docker_email"
  _exec_remote_cmd $host "$docker_login_cmd"
}

generate_system_config() {
  __process_msg "Inserting data into systemConfigs Table"
  local db_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="db")')
  local host=$(echo $db_host | jq '.ip')
  local db_ip=$(echo $db_host | jq '.ip')

  #TODO: put sed update into a function and call it for each variable
  local system_configs_template="$REMOTE_SCRIPTS_DIR/systemConfigsData.sql.template"
  local system_configs_sql="$REMOTE_SCRIPTS_DIR/system_configs_data.sql"

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

  __process_msg "Updating : cachingEnabled"
  local caching_enabled=$(cat $STATE_FILE | jq -r '.systemSettings.cachingEnabled')
  sed -i "s#{{CACHING_ENABLED}}#$caching_enabled#g" $system_configs_sql

  __process_msg "Updating : hubspotEnabled"
  local hubspot_enabled=$(cat $STATE_FILE | jq -r '.systemSettings.hubspotEnabled')
  sed -i "s#{{HUBSPOT_ENABLED}}#$hubspot_enabled#g" $system_configs_sql

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
  local api_url=""
  local domain_protocol=$(cat $STATE_FILE | jq '.systemSettings.domainProtocol')
  local domain=$(cat $STATE_FILE | jq '.systemSettings.domain')
  if [ "$domain" == "localhost" ]; then
    api_url="http://$LOCAL_BRIDGE_IP:$api_port"
  else
    #api_url="$domainProtocol://api.$domain"
    api_url=$(cat $STATE_FILE | jq -r '.systemSettings.apiUrl')
  fi
  sed -i "s#{{API_URL}}#$api_url#g" $system_configs_sql

  __process_msg "Updating : apiPort"
  local api_port=$(cat $STATE_FILE | jq -r '.systemSettings.apiPort')
  sed -i "s#{{API_PORT}}#$api_port#g" $system_configs_sql

  __process_msg "Updating : wwwUrl"
  local www_url=""
  local www_port=50001
  if [ "$domain" == "localhost" ]; then
    www_url="http://$LOCAL_BRIDGE_IP:$www_port"
  else
    #www_url="$domainProtocol://$domain"
    www_url=$(cat $STATE_FILE | jq -r '.systemSettings.wwwUrl')
  fi
  sed -i "s#{{WWW_URL}}#$www_url#g" $system_configs_sql

  __process_msg "Updating : runMode"
  local run_mode=$(cat $STATE_FILE | jq -r '.systemSettings.runMode')
  sed -i "s#{{RUN_MODE}}#$run_mode#g" $system_configs_sql

  __process_msg "Updating : rootQueueList"
  local root_queue_list=$(cat $STATE_FILE | jq -r '.systemSettings.rootQueueList')
  sed -i "s#{{ROOT_QUEUE_LIST}}#$root_queue_list#g" $system_configs_sql

  __process_msg "Updating : createdAt"
  local created_at=$(date)
  sed -i "s#{{CREATED_AT}}#$created_at#g" $system_configs_sql

  __process_msg "Updating : updatedAt"
  sed -i "s#{{UPDATED_AT}}#$created_at#g" $system_configs_sql

  __process_msg "Successfully generated 'systemConfig' table data"
}

provision_api() {
  __process_msg "Provisioning api"
  local api_service_image=$(cat $STATE_FILE | jq '.services[] | select (.name=="api") | .image')
  __process_msg "Successfully read from state.json: api.image ($api_service_image)"

  local api_env_vars=$(cat $CONFIG_FILE | jq '
    .services[] |
    select (.name=="api") | .envs')
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
    else
      echo "No handler for API env : $env_var, exiting"
      exit 1
    fi
  done

  __process_msg "Successfully generated api environment variables : $api_env_values"

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
  __process_msg "Successfully generated api serivce config"

  __process_msg "Provisioning api on swarm cluster"
  local swarm_manager_machine=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="swarm")')
  local swarm_manager_host=$(echo $swarm_manager_machine | jq '.ip')

  local port_mapping=$(cat $STATE_FILE | jq -r '.services[] | select (.name=="api") | .port')
  local env_variables=$(cat $STATE_FILE | jq -r '.services[] | select (.name=="api") | .env')
  local name=$(cat $STATE_FILE | jq -r '.services[] | select (.name=="api") | .name')
  local opts=$(cat $STATE_FILE | jq -r '.services[] | select (.name=="api") | .opts')
  local image=$(cat $STATE_FILE | jq -r '.services[] | select (.name=="api") | .image')

  local boot_api_cmd="sudo docker service create \
    $port_mapping \
    $env_variables \
    $opts $image"

  _exec_remote_cmd "$swarm_manager_host" "$boot_api_cmd"
  __process_msg "Successfully provisioned api"
}

insert_system_config() {
  # TODO: This should ideally check if the API is _actually_ up and running.
  __process_msg "Waiting 60s for API to come up..."
  sleep 60
  __process_msg "Inserting data into systemConfigs Table"
  local db_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="db")')
  local db_ip=$(echo $db_host | jq -r '.ip')
  local db_username=$(cat $STATE_FILE | jq -r '.systemSettings.dbUsername')

  #TODO: fetch db_name from state.json
  local db_name="shipdb"

  _copy_script_remote $db_ip "system_configs_data.sql" "$SCRIPT_DIR_REMOTE"
  _exec_remote_cmd $db_ip "psql -U $db_username -h $db_ip -d $db_name -f $SCRIPT_DIR_REMOTE/system_configs_data.sql"
}

run_migrations() {
  __process_msg "Running migrations.sql"

  local db_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="db")')
  local db_ip=$(echo $db_host | jq -r '.ip')
  local db_username=$(cat $STATE_FILE | jq -r '.systemSettings.dbUsername')
  local db_name="shipdb"

  __process_msg "Please copy migrations.sql onto $db_ip: $SCRIPT_DIR_REMOTE/, type (y) when done"
  __process_msg "Done? (y/n)"
  read response
  if [[ "$response" =~ "y" ]]; then
    __process_msg "Proceeding with steps to run migrations"
    _exec_remote_cmd $db_ip "psql -U $db_username -h $db_ip -d $db_name -f $SCRIPT_DIR_REMOTE/migrations.sql"
  else
    __process_msg "Migrations are required to install core"
    run_migrations
  fi
}

insert_system_integrations() {
  __process_msg "Inserting system integrations"
  local api_url=""
  local api_token=$(cat $STATE_FILE | jq -r '.systemSettings.serviceUserToken')
  local domain=$(cat $STATE_FILE | jq '.systemSettings.domain')
  if [ "$domain" == "localhost" ]; then
    api_url="http://$LOCAL_BRIDGE_IP:$api_port"
  else
    api_url=$(cat $STATE_FILE | jq -r '.systemSettings.apiUrl')
  fi
  local system_integrations=$(cat $STATE_FILE | jq -r '.systemIntegrations')
  local system_integrations_count=$(echo $system_integrations | jq '. | length')
  local system_integration_post_endpoint="$api_url/systemIntegrations"

  for i in $(seq 1 $system_integrations_count); do
    local system_integration=$(echo $system_integrations | jq -r '.['"$i-1"']')
    local system_integration_name=$(echo $system_integration | jq -r '.name')
    local post_call_resp_code=$(curl -H "Content-Type: application/json" -H "Authorization: apiToken $api_token" \
      -X POST -d "$system_integration" $system_integration_post_endpoint \
        --write-out "%{http_code}\n" --silent --output /dev/null)
    if [ "$post_call_resp_code" -gt "299" ]; then
      echo "Error inserting system integration $system_integration_name(status code $post_call_resp_code)"
    else
      echo "Sucessfully inserted system integration $system_integration_name"
    fi
  done
}

main() {
  __process_marker "Updating system config"
  generate_serviceuser_token
  update_docker_creds
  generate_system_config
  provision_api
  insert_system_config
  run_migrations
  insert_system_integrations
}

main
