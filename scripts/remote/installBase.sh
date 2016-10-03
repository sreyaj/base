#!/bin/bash -e

add_keys() {
  apt-get install -y apt-transport-https ca-certificates
  apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

  wget http://www.rabbitmq.com/rabbitmq-signing-key-public.asc
  apt-key add rabbitmq-signing-key-public.asc

  wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | apt-key add -
}

update_sources() {
  rabbitmq_deb="deb http://www.rabbitmq.com/debian/ testing main"
  cat /etc/apt/sources.list | grep $rabbitmq_deb
  exit_status=$?
  if [ exit_status -eq 1 ]; then
    echo $rabbitmq_deb >> /etc/apt/sources.list
  fi
  docker_deb="deb https://apt.dockerproject.org/repo ubuntu-trusty main"
  cat /etc/apt/sources.list.d/docker.list | grep $docker_deb
  exit_status=$?
  if [ exit_status -eq 1 ]; then
    echo $docker_deb | tee -a /etc/apt/sources.list.d/docker.list
  fi
  postgresql_deb="deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main"
  cat /etc/apt/sources.list.d/pgdg.list | grep $postgresql_deb
  exit_status=$?
  if [ exit_status -eq 1 ]; then
    echo $postgresql_deb | tee -a /etc/apt/sources.list.d/pgdg.list
  fi
}

install_base_binaries() {
  apt-get -y update
  apt-get install -y jq vim git-core
}

main() {
  add_keys
  update_sources
  install_base_binaries
}

main
