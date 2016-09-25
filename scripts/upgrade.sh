#!/bin/bash -e

update_service() {
  local service_name="$1"
  local service_image="$2"

  local current_service_image=$(cat $STATE_FILE | jq -r '
    .services[] | select (.name=="'$service_name'") | .image')

  if [ -z "$current_service_image" ]; then
    __process_msg "No services defined by the name $service_name, exiting"
    exit 1
  fi
  __process_msg "Current service image : $current_service_image"
  __process_msg "Updating service $service_name with image $service_image"

  local update_command="sudo docker service update --with-registry-auth\
    --image $service_image \
    $service_name"

  __process_msg "Getting swarm master address"
  local swarm_host=$(cat $STATE_FILE | jq '.machines[] | select (.group=="core" and .name=="swarm")')
  local host=$(echo "$swarm_host" | jq -r '.ip')

  __process_msg "Swarm master address: $host"
  _exec_remote_cmd "$host" "$update_command"
}

main() {
  update_service $@
}

main $@
