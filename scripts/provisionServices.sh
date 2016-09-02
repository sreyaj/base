#!/bin/bash -e

readonly SERVICE_CONFIG="$DATA_DIR/config.json"
readonly WAIT_TIME_SECS=20
readonly SERVICES_SWARM_NETWORK=ingress

load_services() {
  # TODO: load service configuration from `config.json`
  local service_count=$(cat $SERVICE_CONFIG | jq '.services | length')
  if [[ $service_count -lt 3 ]]; then
    echo "Shippable requires at least api, www and sync to boot"
    exit 1
  else
    echo "Service count : $service_count"
  fi
}

provision_api() {
  echo "provisioning api"
  local api_service=$(cat $SERVICE_CONFIG | jq '.services[] | select (.name=="api")')
  local api_service_image=$(echo $api_service | jq '.image')
  local api_env_vars=$(echo $api_service | jq '.envs')
  local api_port=50000

  local api_url=""
  local domain_protocol=$(cat $STATE_FILE | jq '.systemConfig.domainProtocol')
  local domain=$(cat $STATE_FILE | jq '.systemConfig.domain')
  if [ "$domain" == "localhost" ]; then
    api_url="localhost:$api_port"
  else
    api_url="$domainProtocol://api.$domain"
  fi
  local vortex_url="$api_url/vortex"

  local api_url=$(cat $STATE_FILE | jq '.services[] | select (.name=="api") | .url')

  local api_env_values=""
  for $env_var in  $api_env_vars; do
    if [ "$env_var" == "SHIPPABLE_API_TOKEN" ]; then
      local api_token=$(cat $STATE_FILE | jq '.systemSettings.serviceUserToken')
      if [ -z "$api_token" ]; then
        echo "$env_var undefined, exiting"
        exit 1
      fi
      api_env_values="$api_env_values -e $env_var=$api_token "
    elif [ "$env_var" == "SHIPPABLE_VORTEX_URL" ]; then
      api_env_values="$api_env_values -e $env_var=$vortex_url"
    else
      echo "No handler for API env : $env_var"
      exit 1
    fi
  done

  local api_state_env=$(cat $STATE_FILE | jq '.services[] | select (.name=="api") | .env="'$api_env_vars'"')
  _update_state "$api_state_env"

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

wait_for_api_boot() {
  #TODO: wait for api to boot confirmation from swarm
  echo "Waiting $WAIT_TIME_SECS seconds for api to boot..."
  sleep $WAIT_TIME_SECS
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

provision_www() {
  echo "provisioning www"
}

provision_sync() {
  echo "provisioning sync"
}

main() {
  provision_api
  #wait_for_api_boot
  #insert_system_config
  #run_migrations
  #provision_www
  #provision_sync
}

main
