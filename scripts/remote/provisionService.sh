#!/bin/bash -e

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly SERVICE_IMAGE="$2"
readonly SERVICE_NAME="$1"
readonly REPLICAS=1

export ENV_LIST=""

parse_env() {
  ##TODO: from the file <service name>.env, parse a string in format
  ## -e key=value -e key1=value1 ...
  local env_file="$SCRIPT_DIR/$SERVICE_NAME.env"
  while IFS='' read -r line || [[ -n "$line" ]]; do
    ENV_LIST="$ENV_LIST -e $line"
  done < "$env_file"
}

provision_service() {
  docker service create \
    --with-registry-auth \
    --name $SERVICE_NAME \
    --replicas $REPLICAS \
    $ENV_LIST $SERVICE_IMAGE 
}

main() {
  parse_env
  provision_service
}

main
