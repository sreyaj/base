#!/bin/bash -e

# Indicates if docker service should be restarted
export docker_restart=false
export INSTALL_MODE="$1"

readonly DOCKER_VERSION=1.12.1-0~trusty

check_docker_local() {
  {
    type docker &> /dev/null && __process_msg "Docker available"
  } || {
    __process_msg "Please install Docker v1.9.1 before running the installer"
    echo -e "\n  sudo apt-get install docker-engine=1.9.1-0~trusty\n"
    exit 1
  }

  {
    docker_version=$(docker -v | grep 1.9.1)
  } || {
    true
  }
  if [ -z $docker_version ]; then
    __process_msg "Please reinstall Docker to v1.9.1 before running the installer using:"
    echo -e "\n  sudo apt-get install docker-engine=1.9.1-0~trusty\n"
    exit 1
  fi
}

docker_install() {
  echo "Installing docker"

  sudo apt-get install -y linux-image-extra-`uname -r` linux-image-extra-virtual
  sudo apt-get install -y docker-engine=$DOCKER_VERSION
}

check_docker_opts() {
  echo "Checking docker options"

  SHIPPABLE_DOCKER_OPTS='DOCKER_OPTS="$DOCKER_OPTS -H unix:///var/run/docker.sock -g=/data --storage-driver aufs"'

  opts_exist=$(sh -c "grep '$SHIPPABLE_DOCKER_OPTS' /etc/default/docker || echo ''")
  if [ -z "$opts_exist" ]; then
    ## docker opts do not exist
    echo "appending DOCKER_OPTS to /etc/default/docker"
    echo "$SHIPPABLE_DOCKER_OPTS" | sudo tee -a /etc/default/docker
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
  if [ "$INSTALL_MODE" == "local" ]; then
    check_docker_local
  else
    docker_install
    check_docker_opts
    restart_docker_service
  fi
}

main
