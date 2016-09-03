#!/bin/bash -e

generate_serviceuser_token() {
  __process_msg "Generating random token for serviceuser"
  local token=$(cat /proc/sys/kernel/random/uuid)
  local stateToken=$(cat $STATE_FILE | jq '.systemSettings.serviceUserToken="'$token'"')
  echo $stateToken > $STATE_FILE
}

generate_system_config() {
  __process_msg "Inserting data into systemConfigs Table"
  local db_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="db")')
  local host=$(echo $db_host | jq '.ip')
  local db_ip=$(echo $db_host | jq '.ip')
  local db_username=$(cat $STATE_FILE | jq '.core[] | select (.name=="postgresql") | .secure.username')

  local system_configs_template="$DATA_DIR/system_configs_data.sql.template"
  local system_configs_sql="$DATA_DIR/system_configs_data.sql"

  local default_minion_count=$(cat $STATE_FILE | jq -r '.systemSettings.defaultMinionCount')
  sed "s/{{DEFAULT_MINION_COUNT}}/$default_minion_count/g" $system_configs_template > $system_configs_sql

  local default_pipeline_count=$(cat $STATE_FILE | jq -r '.systemSettings.defaultPipelineCount')
  sed -i "s/{{DEFAULT_PIPELINE_COUNT}}/$default_pipeline_count/g" $system_configs_sql

  local braintree_enabled=$(cat $STATE_FILE | jq -r '.systemSettings.braintreeEnabled')
  sed -i "s/{{BRAINTREE_ENABLED}}/$braintree_enabled/g" $system_configs_sql

  local build_timeout=$(cat $STATE_FILE | jq -r '.systemSettings.buildTimeoutMS')
  sed -i "s/{{BUILD_TIMEOUT_MS}}/$build_timeout/g" $system_configs_sql

  local private_job_quota=$(cat $STATE_FILE | jq -r '.systemSettings.defaultPrivateJobQuota')
  sed -i "s/{{DEFAULT_PRIVATE_JOB_QUOTA}}/$private_job_quota/g" $system_configs_sql

  local serviceuser_token=$(cat $STATE_FILE | jq -r '.systemSettings.serviceUserToken')
  sed -i "s/{{SERVICE_USER_TOKEN}}/$serviceuser_token/g" $system_configs_sql

  local vault_url=$(cat $STATE_FILE | jq -r '.systemSettings.vaultUrl')
  sed -i "s/{{VAULT_URL}}/$vault_url/g" $system_configs_sql

  local vault_token=$(cat $STATE_FILE | jq -r '.systemSettings.vaultToken')
  sed -i "s/{{VAULT_TOKEN}}/$vault_token/g" $system_configs_sql

  local vault_refresh_time=$(cat $STATE_FILE | jq -r '.systemSettings.vaultRefreshTimeInSec')
  sed -i "s/{{VAULT_REFRESH_TIME_SEC}}/$vault_refresh_time/g" $system_configs_sql

  local caching_enabled=$(cat $STATE_FILE | jq -r '.systemSettings.cachingEnabled')
  sed -i "s/{{CACHING_ENABLED}}/$caching_enabled/g" $system_configs_sql

  local hubspot_enabled=$(cat $STATE_FILE | jq -r '.systemSettings.hubspotEnabled')
  sed -i "s/{{HUBSPOT_ENABLED}}/$hubspot_enabled/g" $system_configs_sql

  local amqp_url=$(cat $STATE_FILE | jq -r '.systemSettings.amqpUrl')
  sed -i "s/{{AMQP_URL}}/$amqp_url/g" $system_configs_sql

  local amqp_admin_url=$(cat $STATE_FILE | jq -r '.systemSettings.amqpAdminUrl')
  sed -i "s/{{AMQP_ADMIN_URL}}/$amqp_url/g" $system_configs_sql

  local amqp_default_exchange=$(cat $STATE_FILE | jq -r '.systemSettings.amqpDefaultExchange')
  sed -i "s/{{AMQP_DEFAULT_EXCHANGE}}/$amqp_default_exchange/g" $system_configs_sql

  local api_url=$(cat $STATE_FILE | jq -r '.systemSettings.apiUrl')
  sed -i "s/{{API_URL}}/$api_url/g" $system_configs_sql

  local api_port=$(cat $STATE_FILE | jq -r '.systemSettings.apiPort')
  sed -i "s/{{API_PORT}}/$api_port/g" $system_configs_sql

  local www_url=$(cat $STATE_FILE | jq -r '.systemSettings.wwwUrl')
  sed -i "s/{{WWW_URL}}/$www_url/g" $system_configs_sql

  local run_mode=$(cat $STATE_FILE | jq -r '.systemSettings.runMode')
  sed -i "s/{{RUN_MODE}}/$run_mode/g" $system_configs_sql

  local root_queue_list=$(cat $STATE_FILE | jq -r '.systemSettings.rootQueueList')
  sed -i "s/{{ROOT_QUEUE_LIST}}/$root_queue_list/g" $system_configs_sql

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

  local api_port=50000

  local api_url=""
  local domain_protocol=$(cat $STATE_FILE | jq '.systemSettings.domainProtocol')
  local domain=$(cat $STATE_FILE | jq '.systemSettings.domain')
  if [ "$domain" == "localhost" ]; then
    api_url="http://localhost:$api_port"
  else
    api_url="$domainProtocol://api.$domain"
  fi

  local api_env_values=""
  for i in $(seq 1 $api_env_vars_count); do
    local env_var=$(echo $api_env_vars | jq -r '.['"$i-1"']')

    if [ "$env_var" == "SHIPPABLE_API_TOKEN" ]; then
      local api_token=$(cat $STATE_FILE | jq '.systemSettings.serviceUserToken')
      if [ -z "$api_token" ]; then
        echo "$env_var undefined, exiting"
        exit 1
      fi
      api_env_values="$api_env_values -e $env_var=$api_token "
    elif [ "$env_var" == "RUN_MODE" ]; then
      local run_mode=$(cat $STATE_FILE | jq -r '.systemSettings.runMode')
      api_env_values="$api_env_values -e $env_var=$runMode"
    else
      echo "No handler for API env : $env_var, exiting"
      exit 1
    fi
  done

  echo $api_env_values
  local api_state_env=$(cat $STATE_FILE | jq '.services[] | select (.name=="api") | .env="'$api_env_vars'"')
  #_update_state "$api_state_env"

  local api_port=" --publish $api_port:$api_port/tcp"
  local api_state_port=$(cat $STATE_FILE | jq '.services[] | select (.name=="api") | .port="'$api_port'"')
  _update_state "$api_state_port"

  local api_state_opts=" --name api --mode global --network ingress --with-registry-auth --endpoint-mode vip"
  _update_state "$api_state_port"

  #local swarm_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="swarm")')
  #local host=$(echo $swarm_host | jq '.ip')

  #_copy_script_remote $host "provisionService.sh" "$SCRIPT_DIR_REMOTE"
  #_exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/provisionService.sh $api_service_image api"
}

insert_system_config() {
  __process_msg "Inserting data into systemConfigs Table"
  local db_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="db")')
  local host=$(echo $db_host | jq '.ip')
  local db_ip=$(echo $db_host | jq '.ip')
  local db_username=$(cat $STATE_FILE | jq '.core[] | select (.name=="postgresql") | .secure.username')

  #TODO: fetch db_name from state.json
  local db_name="shipdb"

  _copy_script_remote $host "$DATA_DIR/system_configs_data.sql" "/tmp"
  _exec_remote_cmd $host "psql -U $db_username -h $db_ip -d $db_name -f /tmp/system_configs_data.sql"
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

insert_system_integrations() {
  __process_msg "Inserting system integrations"
  ##TODO:
  # get the api token from state
  # get the api url from state
  # get the system integrations from global config
  # generate system integration objects from  global config
  # call POST /systemIntegrations to insert those in database
}

main() {
  __process_marker "Updating system config"
  generate_serviceuser_token
  generate_system_config
  #provision_api
  # -- this wil create all the tables
  # -- api will be stuck in loop because of no amqp url and other settin
  #insert_system_config
  # -- this will insert token
  # -- this will insert amqp url and other stuff
  #run_migrations
  # -- update/edit tables 
  # -- this will create service user
  #insert_system_integrations
  # insert system integrations
  #update_system_config
}

main
