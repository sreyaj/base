#!/bin/bash -e

###########################################################
#
# Shippable Enterprise Installer
#
# Supported OS: Ubuntu 14.04
# Supported bash: 4.3.11
###########################################################

# Global variables ########################################
###########################################################
readonly INSTALLER_VERSION=4.0.0
readonly IFS=$'\n\t'
readonly ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly SCRIPTS_DIR="$ROOT_DIR/scripts"
readonly DATA_DIR="$ROOT_DIR/data"
readonly STATE_FILE="$DATA_DIR/state.json"
readonly SSH_USER="root"
readonly SSH_PRIVATE_KEY=$DATA_DIR/machinekey
readonly SSH_PUBLIC_KEY=$DATA_DIR/machinekey.pub
readonly SCRIPT_DIR_REMOTE="/tmp/shippable/$RUN_NUMBER"
readonly REMOTE_DIR="/tmp/shippable/$RUN_NUMBER"

# TODO: This should be set from statefile
export RUN_NUMBER=1

source "$SCRIPTS_DIR/_execScriptRemote.sh"
source "$SCRIPTS_DIR/_copyScriptRemote.sh"

# Helper methods ##########################################
###########################################################
__process_marker() {
  local prompt="$@"
  echo ""
  echo "##################################################"
  echo "# $prompt"
  echo "##################################################"
}

__process_msg() {
  local message="$@"
  echo "|___ $@"
}

__check_dependencies() {
  __process_marker "Installing dependencies"

  {
    type jq &> /dev/null && __process_msg "'jq' already installed, skipping"
  } || {
    __process_msg "Installing 'jq'"
    sudo apt-get install -y jq
  }

  {
    type rsync &> /dev/null && __process_msg "'rsync' already installed, skipping"
  } || {
    __process_msg "Installing 'rsync'"
    sudo apt-get install -y rsync
  }

  {
    type ssh &> /dev/null && __process_msg "'ssh' already installed, skipping"
  } || {
    __process_msg "Installing 'ssh'"
    sudo apt-get install -y ssh-client
  }
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
  echo "
  usage: $0 options
  This script installs Shippable enterprise
  OPTIONS:
    -s | --status     Print status of current installation
    -i | --install    Start a new Shippable installation
    -u | --upgrade    Upgrade existing Shippable installation
    -v | --version    Print version of this script
    -h | --help       Print this message
  "
}

__show_status() {
  echo "All services operational"
}

__show_version() {
  echo "Installer version $INSTALLER_VERSION"
}

# Use -gt 1 to consume two arguments per pass in the loop (e.g. each
# argument has a corresponding value to go with it).
# Use -gt 0 to consume one or more arguments per pass in the loop (e.g.
# some arguments don't have a corresponding value to go with it such
# as in the --default example).

## If size is not two at least, quit
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
