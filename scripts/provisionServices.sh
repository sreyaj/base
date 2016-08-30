#!/bin/bash -e

readonly SERVICE_CONFIG="$DATA_DIR/config.json"

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

  _copy_script_remote $host "provisionService.sh" "$SCRIPT_DIR_REMOTE"
  _exec_remote_cmd "$host" "$SCRIPT_DIR_REMOTE/provisionService.sh $api_service_image api"
}

provision_www() {
  echo "provisioning www"
}

provision_sync() {
  echo "provisioning sync"
}

main() {
  provision_api
  provision_www
  provision_sync
}

main
