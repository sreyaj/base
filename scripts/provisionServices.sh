#!/bin/bash -e

load_services() {
  # TODO: load service configuration from `config.json`
  echo "loading services to provision"
}

provision_api() {
  echo "provisioning api"
}

provision_www() {
  echo "provisioning www"
}

main() {
  provision_api
  provision_www
}

main
