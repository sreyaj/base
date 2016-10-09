#!/bin/bash -e

export INSTALL_MODE="$1"

update_sources_docker() {
  sudo apt-get install -y apt-transport-https ca-certificates
  sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

  docker_deb="deb https://apt.dockerproject.org/repo ubuntu-trusty main"
  docker=$(cat /etc/apt/sources.list.d/docker.list 2>/dev/null | grep "$docker_deb") || true
  if [ -z "$docker" ]; then
    echo $docker_deb | tee -a /etc/apt/sources.list.d/docker.list
  fi
}

update_sources_rabbitmq() {
  wget -O- https://www.rabbitmq.com/rabbitmq-release-signing-key.asc | apt-key add -

  rabbitmq_deb="deb http://www.rabbitmq.com/debian/ testing main"
  rabbitmq=$(cat /etc/apt/sources.list 2>/dev/null | grep "$rabbitmq_deb") || true
  if [ -z "$rabbitmq" ]; then
    echo $rabbitmq_deb >> /etc/apt/sources.list
  fi
}

update_sources_postgresql() {
  wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | apt-key add -

  postgresql_deb="deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main"
  postgres=$(cat /etc/apt/sources.list.d/pgdg.list 2>/dev/null | grep "$postgresql_deb") || true
  if [ -z "$postgres" ]; then
    echo $postgresql_deb | tee -a /etc/apt/sources.list.d/pgdg.list
  fi
}

install_base_binaries() {
  sudo apt-get -y update
  sudo apt-get install -y jq vim git-core
}

main() {
  update_sources_docker
  if [ "$INSTALL_MODE" == "production" ]; then
    update_sources_rabbitmq
    update_sources_postgresql
    install_base_binaries
  fi
}

main
