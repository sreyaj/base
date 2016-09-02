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


provision_www() {
  echo "provisioning www"
}

provision_sync() {
  echo "provisioning sync"
}

main() {
  __process_marker "Provisioning services"
  load_services
  #provision_www
  #provision_sync
}

main
