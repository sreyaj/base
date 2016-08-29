#!/bin/bash -e

install_deps() {
  echo "installing dependencies"
  sudo apt-get -y install curl openssh-server ca-certificates
}

install_gitlab() {
  echo "installing Gitlab"
  curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
  sudo apt-get -y install gitlab-ce
}

configure_and_start() {
  echo "configuring and starting gitlab"
  sudo gitlab-ctl reconfigure
}

main() {
  {
    type gitlab-ctl &> /dev/null && echo "Gitlab already installed, skipping" && return
  }

  install_deps
  install_gitlab
  configure_and_start
}

main
