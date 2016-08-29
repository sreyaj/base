#!/bin/bash -e

install_base_binaries() {
  sudo apt-get -y update
  sudo apt-get install -y jq vim git-core
}

main() {
  install_base_binaries
}

main
