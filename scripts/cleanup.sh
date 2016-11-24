#!/bin/bash -e

cleanup() {
  local deploy_version=$(cat $STATE_FILE \
    | jq -r '.deployTag')

  local running_services=$(cat $STATE_FILE \
    | jq '.services')
  local running_services_count=$(echo $running_services \
    | jq '. | length')

  local service_machines_list=$(cat $STATE_FILE \
    | jq '[ .machines[] | select(.group=="services") ]')
  local service_machines_count=$(echo $service_machines_list \
    | jq '. | length')
  for i in $(seq 1 $service_machines_count); do
    local machine=$(echo $service_machines_list \
      | jq '.['"$i-1"']')
    local host=$(echo $machine \
      | jq -r '.ip')

    __process_msg "Cleaning up stale images on: $host"
    _copy_script_remote $host "$REMOTE_SCRIPTS_DIR/cleanup.sh" "$SCRIPT_DIR_REMOTE"

    for j in $(seq 1 $running_services_count); do
      local running_service=$(echo $running_services \
        | jq '.['"$j-1"']')
      local running_service_name=$(echo $running_service \
        | jq -r '.name')
      local running_service_image=$(echo $running_service \
        | jq -r '.image')
      running_service_image=$(echo $running_service_image \
        | tr ":" " " \
        | awk '{print $1}')

      __process_msg "Cleaning up tags for: $running_service_image"
      _exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/cleanup.sh $running_service_image $deploy_tag"
    done
  done
}

main() {
  __process_marker "Cleaning up stale images"
  
  if [ "$INSTALL_MODE" == "production" ]; then
    cleanup
  else
    __process_msg "Installer running locally, not performing cleanup"
  fi
}

main
