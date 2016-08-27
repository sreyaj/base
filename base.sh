#!/bin/bash -e

###########################################################
#
# Shippable Enterprise Installer
# 
# supported OS: ubuntu 14.04
# supported bash: 4.3.11
###########################################################

############ Global variables #############################
###########################################################
readonly INSTALLER_VERSION=4.0.0
readonly IFS=$'\n\t'
readonly ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly SCRIPTS_DIR="$ROOT_DIR/scripts"
readonly DATA_DIR="$ROOT_DIR/data"
readonly STATE_FILE="$DATA_DIR/state.json"
source "$SCRIPTS_DIR/execRemoteCmd.sh"

###########################################################

__process_marker() {
  local prompt="$@"
  echo "##################################################"
  echo "Running $prompt"
  echo "##################################################"
  echo ""
}

__check_dependencies() {
  __process_marker "Installing dependencies"
  {
    type jq >/dev/null 2>&1 
    echo "'jq' already installed, skipping"
  }|| {
    sudo apt-get install -y jq
  }

  ##TODO: check ssh and install if not present
}


install() {
  __check_dependencies
  source "$SCRIPTS_DIR/getConfigs.sh"
  source "$SCRIPTS_DIR/bootstrapMachines.sh"
  source "$SCRIPTS_DIR/installCore.sh"
  source "$SCRIPTS_DIR/bootstrapApp.sh"
  source "$SCRIPTS_DIR/provisionServices.sh"
}

upgrade() {
  echo "Starting upgrades"

}

__print_help() {
  echo "usage: $0 options
  This script installs Shippable enterprise
  OPTIONS:
    -s | --status     Print status of current installation
    -i | --install    Print status of current installation
    -u | --upgrade    Print status of current installation
    -v | --version    Print version of this script 
    -h | --help       Print this message
  "
}


__show_status() {
  echo "All services operational"
  echo $ROOT_DIR
}

__show_version() {
  echo "Installer version $INSTALLER_VERSION"
}

# Use -gt 1 to consume two arguments per pass in the loop (e.g. each
# argument has a corresponding value to go with it).
# Use -gt 0 to consume one or more arguments per pass in the loop (e.g.
# some arguments don't have a corresponding value to go with it such
# as in the --default example).

## if size is not two at least, quit
if [[ $# -gt 0 ]]; then
  while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -s|--status) __show_status
          shift ;;
        -v|--version) __show_version
          shift ;;
        -i|--install) install
          shift ;;
        -u|--upgrade) upgrade
          shift ;;
        -h|--help) __print_help
          shift ;;
        *)
          __print_help
          shift ;;
      esac
    shift
  done
else
  __print_help
fi
