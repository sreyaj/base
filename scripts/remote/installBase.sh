#!/bin/bash -e

install_base_binaries() {
  apt-get -y update
  apt-get install -y jq vim git-core
}

main() {
  install_base_binaries
}

main
