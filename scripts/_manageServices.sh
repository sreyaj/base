#!/bin/bash -e

release_file="$VERSIONS_DIR/$RELEASE_VERSION".json

__add_service() {
  local service_name="$1"

  local service=$(cat $release_file | jq -c '.serviceConfigs[] | select (.name=='$service_name')')
  if [ ! -z "$service" ]; then
    service=$(cat $STATE_FILE | jq '.services[] | select (.name=='$service_name')')
    if [ -z "$service" ]; then
      __process_msg "no $service_name service in state.json, creating new one"
      service=$(cat $STATE_FILE |  \
        jq '.services |= . + [{
          "name": '$service_name',
          "image": "",
          "env": ""
        }]')
      update=$(echo $service | jq '.' | tee $STATE_FILE)
    fi
  fi
}

add_core_services() {
  local core_services=$(cat $release_file | jq '.coreServices')
  local core_services_count=$(echo $core_services | jq '. | length')
  for i in $(seq 1 $core_services_count); do
    local core_service=$(echo $core_services | jq '.['"$i-1"']')
    __add_service "$core_service"
  done
}

add_master_integration_services() {
  local master_integrations=$(cat $STATE_FILE | jq '.masterIntegrations')
  local master_integrations_count=$(echo $master_integrations | jq '. | length')
  for i in $(seq 1 $master_integrations_count); do
    local master_integration_service=$(echo $master_integrations | jq '.['"$i-1"'] | .name')
    local integration_services=$(cat $release_file | jq -c '[ .integrationServices[] | select (.name == '$master_integration_service') | .services[] ]')
    local integration_services_count=$(echo $integration_services | jq '. | length')
    for i in $(seq 1 $integration_services_count); do
      local service=$(echo $integration_services | jq '.['"$i-1"']')
      __add_service "$service"
    done
  done
}

main() {
  __process_marker "Configuring services list"

  add_core_services
  add_master_integration_services
  __process_msg "Configured services list"
}

main
