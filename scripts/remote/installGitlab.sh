#!/bin/bash -e
export GITLAB_VERSION=8.9.6-ce.0
install_deps() {
  echo "installing dependencies"
  apt-get -y install curl openssh-server ca-certificates
}

install_gitlab() {
  echo "installing Gitlab"
  curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | bash
  apt-get -y install gitlab-ce=$GITLAB_VERSION
}

configure_and_start() {
  echo "configuring and starting gitlab"
  gitlab-ctl reconfigure
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
