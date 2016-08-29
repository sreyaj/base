#!/bin/bash -e

readonly DOCKER_VERSION=1.11.1-0~trusty

# Indicates if docker service should be restarted
export docker_restart=false

_run_update() {
  sudo apt-get update
}

upgrade_kernel() {
  echo 'deb http://archive.ubuntu.com/ubuntu/ trusty-proposed restricted main multiverse universe' | sudo tee -a /etc/apt/sources.list
  echo -e 'Package: *\nPin: release a=trusty-proposed\nPin-Priority: 400' | sudo tee -a  /etc/apt/preferences.d/proposed-updates
  _run_update
  sudo apt-get -y  install linux-image-3.19.0-51-generic linux-image-extra-3.19.0-51-generic
}

docker_install() {
  echo "Installing docker"

  _run_update

  sudo apt-get install -y apt-transport-https ca-certificates

  sudo apt-get install -y linux-image-extra-`uname -r`

  sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

  echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" | sudo tee -a /etc/apt/sources.list.d/docker.list

  _run_update

  sudo apt-get install -y docker-engine=$DOCKER_VERSION

}

check_docker_opts() {
  echo "Checking docker options"

  SHIPPABLE_DOCKER_OPTS='DOCKER_OPTS="$DOCKER_OPTS -H unix:///var/run/docker.sock -g=/data --storage-driver aufs"'
  opts_exist=$(sudo sh -c "grep '$SHIPPABLE_DOCKER_OPTS' /etc/default/docker || echo ''")

  if [ -z "$opts_exist" ]; then
    ## docker opts do not exist
    echo "appending DOCKER_OPTS to /etc/default/docker"
    sudo sh -c "echo '$SHIPPABLE_DOCKER_OPTS' >> /etc/default/docker"
    docker_restart=true
  else
    echo "Shippable docker options already present in /etc/default/docker"
  fi

  ## remove the docker option to listen on all ports
  echo "Disabling docker tcp listener"
  sudo sh -c "sed -e s/\"-H tcp:\/\/0.0.0.0:4243\"//g -i /etc/default/docker"
}

restart_docker_service() {
  echo "checking if docker restart is necessary"
  if [ $docker_restart == true ]; then
    echo "restarting docker service on reset"
    sudo service docker restart
  else
    echo "docker_restart set to false, not restarting docker daemon"
  fi
}

main() {
  {
    check_docker=$(sudo service --status-all 2>&1 | grep docker)
  } || {
    true
  }
  if [ ! -z "$check_docker" ]; then
    echo "Docker already installed, skipping."
    return
  fi

  upgrade_kernel
  docker_install
  check_docker_opts
  restart_docker_service
}

main
