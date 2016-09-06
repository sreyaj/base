#!/bin/bash -e

readonly SERVICE_CONFIG="$DATA_DIR/config.json"

load_services() {
  # TODO: load service configuration from `config.json`
  local service_count=$(cat $SERVICE_CONFIG | jq '.services | length')
  if [[ $service_count -lt 3 ]]; then
    __process_msg "Shippable requires at least api, www and sync to boot"
    exit 1
  else
    __process_msg "Service count : $service_count"
  fi
}

__map_env_vars() {
  if [ "$1" == "SHIPPABLE_API_TOKEN" ]; then
    env_value=$(cat $STATE_FILE | jq -r '.systemSettings.serviceUserToken')
  elif [ "$1" == "SHIPPABLE_VORTEX_URL" ]; then
    env_value=$(cat $STATE_FILE | jq -r '.systemSettings.apiVortexUrl')
  elif [ "$1" == "SHIPPABLE_API_URL" ]; then
    env_value=$(cat $STATE_FILE | jq -r '.systemSettings.apiUrl')
  elif [ "$1" == "SHIPPABLE_WWW_PORT" ]; then
    env_value=50001
  elif [ "$1" == "SHIPPABLE_WWW_URL" ]; then
    env_value=$(cat $STATE_FILE | jq -r '.systemSettings.wwwUrl')
  elif [ "$1" == "SHIPPABLE_FE_URL" ]; then
    env_value=$(cat $STATE_FILE | jq -r '.systemSettings.wwwUrl')
  elif [ "$1" == "LOG_LEVEL" ]; then
    env_value=info
  elif [ "$1" == "SHIPPABLE_RDS_URL" ]; then
    env_value=$(cat $STATE_FILE | jq -r '.systemSettings.redisUrl')
  elif [ "$1" == "SHIPPABLE_ROOT_AMQP_URL" ]; then
    env_value=$(cat $STATE_FILE | jq -r '.systemSettings.amqpUrlRoot')
  elif [ "$1" == "SHIPPABLE_AMQP_DEFAULT_EXCHANGE" ]; then
    env_value=$(cat $STATE_FILE | jq -r '.systemSettings.amqpDefaultExchange')
  elif [ "$1" == "RUN_MODE" ]; then
    env_value=production
  # TODO: Populate this
  elif [ "$1" == "SHIPPABLE_AWS_ACCOUNT_ID" ]; then
    env_value=null
  # TODO: Populate this
  elif [ "$1" == "GITHUB_LINK_SYSINT_ID" ]; then
    env_value=null
  # TODO: Populate this
  elif [ "$1" == "BITBUCKET_LINK_SYSINT_ID" ]; then
    env_value=null
  elif [ "$1" == "BITBUCKET_CLIENT_ID" ]; then
    env_value=null
  elif [ "$1" == "BITBUCKET_CLIENT_SECRET" ]; then
    env_value=null
  elif [ "$1" == "COMPONENT" ]; then
    env_value=$2
  else
    echo "No handler for env : $1, exiting"
    exit 1
  fi
}

__save_service_config() {
  local service=$1
  local ports=$2
  local opts=$3
  local component=$4

  __process_msg "Saving config for $service"
  local env_vars=$(cat $CONFIG_FILE | jq --arg service "$service" '
    .services[] |
    select (.name==$service) | .envs')
  __process_msg "Found envs for $service: $env_vars"

  local env_vars_count=$(echo $env_vars | jq '. | length')
  __process_msg "Successfully read from config.json: $service.envs ($env_vars_count)"

  for i in $(seq 1 $env_vars_count); do
    local env_var=$(echo $env_vars | jq -r '.['"$i-1"']')
    __map_env_vars $env_var $component
    env_values="$env_values -e $env_var=$env_value"
  done

  local state_env=$(cat $STATE_FILE | jq --arg service "$service" '
    .services  |=
    map(if .name==$service then
        .env = "'$env_values'"
      else
        .
      end
    )'
  )
  update=$(echo $state_env | jq '.' | tee $STATE_FILE)

  # Ports
  __process_msg "Generating $service port mapping"
  # TODO: Fetch from systemConfig
  local port_mapping=$ports
  __process_msg "$service port mapping : $port_mapping"

  if [ ! -z $ports ]; then
    local port_update=$(cat $STATE_FILE | jq --arg service "$service" '
      .services  |=
      map(if .name == $service then
          .port = "'$port_mapping'"
        else
          .
        end
      )'
    )
    update=$(echo $port_update | jq '.' | tee $STATE_FILE)
    __process_msg "Successfully updated $service port mapping"
  fi

  # Opts
  __process_msg "Generating $service opts"
  # TODO: Fetch from systemConfig
  local opts=$3
  __process_msg "$service opts : $opts"

  if [ ! -z $opts ]; then
    local opt_update=$(cat $STATE_FILE | jq --arg service "$service" '
      .services  |=
      map(if .name == $service then
          .opts = "'$opts'"
        else
          .
        end
      )'
    )
    update=$(echo $opt_update | jq '.' | tee $STATE_FILE)
    __process_msg "Successfully updated $service opts"
  fi
}

__run_service() {
  service=$1
  __process_msg "Provisioning $service on swarm cluster"
  local swarm_manager_machine=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="swarm")')
  local swarm_manager_host=$(echo $swarm_manager_machine | jq '.ip')

  local port_mapping=$(cat $STATE_FILE | jq --arg service "$service" -r '.services[] | select (.name==$service) | .port')
  local env_variables=$(cat $STATE_FILE | jq --arg service "$service" -r '.services[] | select (.name==$service) | .env')
  local name=$(cat $STATE_FILE | jq --arg service "$service" -r '.services[] | select (.name==$service) | .name')
  local opts=$(cat $STATE_FILE | jq --arg service "$service" -r '.services[] | select (.name==$service) | .opts')
  local image=$(cat $STATE_FILE | jq --arg service "$service" -r '.services[] | select (.name==$service) | .image')

  local boot_cmd="sudo docker service create"

  if [ $port_mapping != "null" ]; then
    boot_cmd="$boot_cmd $port_mapping"
  fi

  if [ $env_variables != "null" ]; then
    boot_cmd="$boot_cmd $env_variables"
  fi

  if [ $opts != "null" ]; then
    boot_cmd="$boot_cmd $opts"
  fi

  boot_cmd="$boot_cmd $image"

  _exec_remote_cmd "$swarm_manager_host" "$boot_cmd"
  __process_msg "Successfully provisioned $service"
}

provision_www() {
  __save_service_config www " --publish 50001:50001/tcp" " --name www --mode global --network ingress --with-registry-auth --endpoint-mode vip"
  __run_service "www"
}

provision_sync() {
  __save_service_config sync "" " --name sync --mode global --network ingress --with-registry-auth --endpoint-mode vip" "sync"
  # The second argument will be used for $component
  __run_service "sync"
}

main() {
  __process_marker "Provisioning services"
  load_services
  # provision_www
  provision_sync
}

main
