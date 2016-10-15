#!/bin/bash -e

readonly release_file="$VERSIONS_DIR/$RELEASE_VERSION".json

export SKIP_STEP=false

load_services() {
  local service_count=$(cat $STATE_FILE | jq '.services | length')
  if [[ $service_count -lt 3 ]]; then
    __process_msg "Shippable requires at least api, www and sync to boot"
    exit 1
  else
    __process_msg "Service count : $service_count"
  fi
}

__map_env_vars() {
  if [ "$1" == "DBNAME" ]; then
    env_value=$(cat $STATE_FILE | jq -r '.systemSettings.dbname')
  elif [ "$1" == "DBUSERNAME" ]; then
    env_value=$(cat $STATE_FILE | jq -r '.systemSettings.dbUsername')
  elif [ "$1" == "DBPASSWORD" ]; then
    env_value=$(cat $STATE_FILE | jq -r '.systemSettings.dbPassword')
  elif [ "$1" == "DBHOST" ]; then
    env_value=$(cat $STATE_FILE | jq -r '.systemSettings.dbHost')
  elif [ "$1" == "DBPORT" ]; then
    env_value=$(cat $STATE_FILE | jq -r '.systemSettings.dbPort')
  elif [ "$1" == "DBDIALECT" ]; then
    env_value=$(cat $STATE_FILE | jq -r '.systemSettings.dbDialect')
  elif [ "$1" == "SHIPPABLE_API_TOKEN" ]; then
    env_value=$(cat $STATE_FILE | jq -r '.systemSettings.serviceUserToken')
  elif [ "$1" == "SHIPPABLE_VORTEX_URL" ]; then
    env_value=$(cat $STATE_FILE | jq -r '.systemSettings.apiUrl')/vortex
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
    env_value=$(cat $STATE_FILE | jq -r '.systemSettings.runMode')
  # TODO: Populate this
  elif [ "$1" == "DOCKER_VERSION" ]; then
    env_value=1.9.1
  elif [ "$1" == "DEFAULT_CRON_LOOP_HOURS" ]; then
    env_value=2
  elif [ "$1" == "API_RETRY_INTERVAL" ]; then
    env_value=3
  elif [ "$1" == "PROVIDERS" ]; then
    env_value=ec2
  elif [ "$1" == "SHIPPABLE_EXEC_IMAGE" ]; then
    local step_exec_image=$(cat $STATE_FILE | jq -r '.systemSettings.stepExecImage')
    env_value=$step_exec_image
  elif [ "$1" == "EXEC_IMAGE" ]; then
    local step_exec_image=$(cat $STATE_FILE | jq -r '.systemSettings.stepExecImage')
    env_value=$step_exec_image
  elif [ "$1" == "SETUP_RUN_SH" ]; then
    env_value=true
  elif [ "$1" == "SHIPPABLE_AWS_ACCOUNT_ID" ]; then
    env_value=null
  elif [ "$1" == "REGISTRY_ACCOUNT_ID" ]; then
    env_value=null
  elif [ "$1" == "REGISTRY_REGION" ]; then
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
  elif [ "$1" == "JOB_TYPE" ]; then
    env_value=$3
  elif [ "$1" == "IRC_BOT_NICK" ]; then
    env_value=shippable-betaone
  else
    echo "No handler for env : $1, exiting"
    exit 1
  fi
}

_check_component_status() {
  local status=$(cat $STATE_FILE | jq '.installStatus.'"$1"'')
  if [ "$status" = true ]; then
    SKIP_STEP=true;
  fi
}

_update_install_status() {
  local update=$(cat $STATE_FILE | jq '.installStatus.'"$1"'='true'')
  _update_state "$update"
}

__save_service_config() {
  local service=$1
  local ports=$2
  local opts=$3
  local component=$4
  local job_type=$5

  __process_msg "Saving image for $service"
  local system_images_registry=$(cat $STATE_FILE | jq -r '.systemSettings.systemImagesRegistry')
  local service_repository=$(cat $release_file | jq -r --arg service "$service" '
    .serviceConfigs[] |
    select (.name==$service) | .repository')
  local service_tag=$service"."$RELEASE_VERSION
  if [ $service == "www" ] || [ $service == "api" ] \
    || [ $service == "nexec" ]; then
    service_tag=$RELEASE_VERSION
  elif [ $service == "deploy" ] || [ $service == "manifest" ] \
    || [ $service == "release" ] || [ $service == "rSync" ]; then
    service_tag="stepExec".$RELEASE_VERSION
  fi
  local service_image="$system_images_registry/$service_repository:$service_tag"
  __process_msg "Image version generated for $service : $service_image"
  local image_update=$(cat $STATE_FILE | jq --arg service "$service" '
    .services  |=
    map(if .name == "'$service'" then
        .image = "'$service_image'"
      else
        .
      end
    )'
  )
  update=$(echo $image_update | jq '.' | tee $STATE_FILE)
  __process_msg "Successfully updated $service port mapping"

  __process_msg "Saving config for $service"
  local env_vars=$(cat $release_file | jq --arg service "$service" '
    .serviceConfigs[] |
    select (.name==$service) | .envs')
  __process_msg "Found envs for $service: $env_vars"

  local env_vars_count=$(echo $env_vars | jq '. | length')
  __process_msg "Successfully read from version file: $service.envs ($env_vars_count)"

  env_values=""
  for i in $(seq 1 $env_vars_count); do
    local env_var=$(echo $env_vars | jq -r '.['"$i-1"']')
    __map_env_vars $env_var $component $job_type
    env_values="$env_values -e $env_var=$env_value"
  done

  # Proxy
  __process_msg "Adding $service proxy mapping"
  http_proxy=$(cat $STATE_FILE | jq -r '.systemSettings.httpProxy')
  https_proxy=$(cat $STATE_FILE | jq -r '.systemSettings.httpsProxy')
  no_proxy=$(cat $STATE_FILE | jq -r '.systemSettings.noProxy')

  if [ ! -z $http_proxy ]; then
    env_values="$env_values -e http_proxy=$http_proxy -e HTTP_PROXY=$http_proxy"
    __process_msg "Successfully updated $service http_proxy mapping"
  fi

  if [ ! -z $https_proxy ]; then
    env_values="$env_values -e https_proxy=$https_proxy -e HTTPS_PROXY=$https_proxy"
    __process_msg "Successfully updated $service https_proxy mapping"
  fi

  if [ ! -z $no_proxy ]; then
    env_values="$env_values -e no_proxy=$no_proxy -e NO_PROXY=$no_proxy"
    __process_msg "Successfully updated $service no_proxy mapping"
  fi

  local state_env=$(cat $STATE_FILE | jq --arg service "$service" '
    .services  |=
    map(if .name == $service then
        .env = "'$env_values'"
      else
        .
      end
    )'
  )
  update=$(echo $state_env | jq '.' | tee $STATE_FILE)

  __process_msg "Generating $service replicas"
  local replicas=$(cat $release_file | jq --arg service "$service" '
    .serviceConfigs[] |
    select (.name==$service) | .replicas')

  if [ $replicas != "null" ]; then
    __process_msg "Found $replicas for $service"
    local replicas_update=$(cat $STATE_FILE | jq --arg service "$service" '
      .services  |=
      map(if .name == $service then
          .replicas = "'$replicas'"
        else
          .
        end
      )'
    )
    update=$(echo $replicas_update | jq '.' | tee $STATE_FILE)
    __process_msg "Successfully updated $service replicas"
  fi

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
  local replicas=$(cat $STATE_FILE | jq --arg service "$service" -r '.services[] | select (.name==$service) | .replicas')

  if [ "$INSTALL_MODE" == "production" ]; then
    local boot_cmd="docker service create"

    if [ $port_mapping != "null" ]; then
      boot_cmd="$boot_cmd $port_mapping"
    fi

    if [ $env_variables != "null" ]; then
      boot_cmd="$boot_cmd $env_variables"
    fi

    if [ $replicas != "null" ]; then
      boot_cmd="$boot_cmd --replicas $replicas"
    else
      boot_cmd="$boot_cmd --mode global"
    fi

    if [ $opts != "null" ]; then
      boot_cmd="$boot_cmd $opts"
    fi

    boot_cmd="$boot_cmd $image"
    _exec_remote_cmd "$swarm_manager_host" "docker service rm $service || true"
    _exec_remote_cmd "$swarm_manager_host" "$boot_cmd"
  else
    sudo docker rm -f $service || true

    boot_cmd="sudo docker run -d "

    if [ $port_mapping != "null" ]; then
      boot_cmd="$boot_cmd $port_mapping"
    fi

    if [ $env_variables != "null" ]; then
      boot_cmd="$boot_cmd $env_variables"
    fi

    boot_cmd="$boot_cmd \
      --net host \
      --name $service \
      $image"

    eval $boot_cmd
  fi
  __process_msg "Successfully provisioned $service"
}

provision_www() {
  __save_service_config www " --publish 50001:50001/tcp" " --name www --network ingress --with-registry-auth --endpoint-mode vip"
  __run_service "www"
}

provision_services() {
  local services=$(cat $STATE_FILE | jq -c '[ .services[] ]')
  local services_count=$(echo $services | jq '. | length')
  local provisioned_services="[\"www\",\"api\"]"
  for i in $(seq 1 $services_count); do
    local service=$(echo $services | jq -r '.['"$i-1"'] | .name')
    local provisioned_service=$(echo $provisioned_services | jq -r '.[] | select (.=="'$service'")')
    if [ -z "$provisioned_service" ]; then
      __save_service_config $service "" " --name $service --network ingress --with-registry-auth --endpoint-mode vip" $service
      __run_service "$service"
    fi
  done
}

remove_services_prod() {
  # local swarm_manager_machine=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="swarm")')
  # local swarm_manager_host=$(echo $swarm_manager_machine | jq '.ip')
  local running_services=$(docker service inspect --format='{{json .Spec.Name}},' $(sudo docker service ls -q))
  running_services="["${running_services::-1}"]"
  local required_services=$(cat $STATE_FILE | jq -c '[ .services[] ]')
  local ship_services=$(cat $release_file | jq -c '[ .serviceConfigs[] | .name]')
  local running_services_count=$(echo $running_services | jq '. | length')
  for i in $(seq 1 $running_services_count); do
    local service=$(echo $running_services | jq -r '.['"$i-1"']')
    if [[ ! $service =~ .*"local".* ]]; then
      local required_service=$(echo $ship_services | jq '.[] | select (.=="'$service'")')
      if [ ! -z "$required_service" ]; then
        required_service=$(echo $required_services | jq -r '.[] | select (.name=="'$service'") | .name')
        if [ -z "$required_service" ]; then
          local removed_service=$(docker service rm $service || true)
          __process_msg "$removed_service service removed"
        fi
      fi
    fi
  done
}


remove_services_local() {
  local running_services=$(echo "$(docker inspect --format='{{json .Name}}' $(docker ps -a -q))" | tr '\n' ',')
  local required_services=$(cat $STATE_FILE | jq -c '[ .services[] ]')
  local ship_services=$(cat $release_file | jq -c '[ .serviceConfigs[] | .name]')
  running_services="["${running_services::-1}"]"
  local running_services_count=$(echo $running_services | jq '. | length')
  for i in $(seq 1 $running_services_count); do
    local service=$(echo $running_services | jq -r '.['"$i-1"']')
    if [[ ! $service =~ .*"local".* ]]; then
      service=${service:1}
      local required_service=$(echo $ship_services | jq '.[] | select (.=="'$service'")')
      if [ ! -z "$required_service" ]; then
        required_service=$(echo $required_services | jq -r '.[] | select (.name=="'$service'") | .name')
        if [ -z "$required_service" ]; then
          local removed_service=$(sudo docker rm -f $service || true)
          __process_msg "$removed_service service removed"
        fi
      fi
    fi
  done
}

main() {
  __process_marker "Provisioning services"
  load_services
  provision_www
  provision_services
  if [ "$INSTALL_MODE" == "production" ]; then
    remove_services_prod
  else
    remove_services_local
  fi
}

main
