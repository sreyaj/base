#!/bin/bash -e

update_sources() {
  echo "deb http://www.rabbitmq.com/debian/ testing main" >> /etc/apt/sources.list
  echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" | tee -a /etc/apt/sources.list.d/docker.list
  echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | tee -a /etc/apt/sources.list.d/pgdg.list
}

install_base_binaries() {
  apt-get -y update
  apt-get install -y jq vim git-core
}

main() {
	update_sources
  install_base_binaries
}

main
