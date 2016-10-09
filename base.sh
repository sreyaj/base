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
export INSTALL_MODE=production
readonly IFS=$'\n\t'
readonly ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly SCRIPTS_DIR="$ROOT_DIR/scripts"
readonly DATA_DIR="$ROOT_DIR/data"
readonly REMOTE_SCRIPTS_DIR="$ROOT_DIR/scripts/remote"
readonly LOCAL_SCRIPTS_DIR="$ROOT_DIR/scripts/local"
readonly STATE_FILE="$DATA_DIR/state.json"
readonly STATE_FILE_BACKUP="$DATA_DIR/state.json.backup"
readonly CONFIG_FILE="$DATA_DIR/config.json"
readonly SSH_USER="root"
readonly SSH_PRIVATE_KEY=$DATA_DIR/machinekey
readonly SSH_PUBLIC_KEY=$DATA_DIR/machinekey.pub
readonly LOCAL_BRIDGE_IP=172.17.42.1
export LC_ALL=C
export RELEASE=""

source "$SCRIPTS_DIR/_execScriptRemote.sh"
source "$SCRIPTS_DIR/_copyScriptRemote.sh"
source "$SCRIPTS_DIR/_copyScriptLocal.sh"
source "$SCRIPTS_DIR/_manageState.sh"

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
    apt-get install -y jq
  }

  {
    type rsync &> /dev/null && __process_msg "'rsync' already installed, skipping"
  } || {
    __process_msg "Installing 'rsync'"
    apt-get install -y rsync
  }

  {
    type ssh &> /dev/null && __process_msg "'ssh' already installed, skipping"
  } || {
    __process_msg "Installing 'ssh'"
    apt-get install -y ssh-client
  }
}

install() {
  __check_dependencies
  RELEASE=$(cat $CONFIG_FILE | jq -r '.release')
  readonly SCRIPT_DIR_REMOTE="/tmp/shippable/$RELEASE"
  source "$SCRIPTS_DIR/getConfigs.sh"
  source "$SCRIPTS_DIR/bootstrapMachines.sh"
  source "$SCRIPTS_DIR/installCore.sh"
  source "$SCRIPTS_DIR/bootstrapApp.sh"
  source "$SCRIPTS_DIR/provisionServices.sh"
}

upgrade() {
  __process_marker "Starting update"
  local service_name="$1"
  local service_image="$2"
  source "$SCRIPTS_DIR/upgrade.sh" "$service_name" "$service_image"

  # TODO:
  # get swarm ip
  # get the service name from statefile
  # generate swarm update command using the new image(from cmd line) and options(from statefile)
  # execute updaate command on swarm machine
}

__print_help_upgrade() {
  echo "
  usage: ./base.sh --upgrade <service_name> <image_name>
  This command updates the <service_name> Shippable component with image tag <image_name>
  "
}

__print_help_install() {
  echo "
  usage: ./base.sh --install [local | production]
  This command installs shippable on either localhost or production environment.
  production environment is chosen by default
  "
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

if [[ $# -gt 0 ]]; then
  key="$1"

  case $key in
    -s|--status) __show_status
      shift ;;
    -v|--version) __show_version
      shift ;;
    -i|--install)
      shift
      if [[ $# -eq 1 ]]; then
        install_mode=$1
      fi
      if [ "$install_mode" == "production" ] || [ "$install_mode" == "local" ]; then
        export INSTALL_MODE="$install_mode"
        install
      else
        __print_help_install
      fi
      ;;
    -u|--upgrade)
      shift
      if [[ $# -ne 2 ]]; then
        __print_help_upgrade
      else
        upgrade $@
        shift 2
      fi
      ;;
    -h|--help) __print_help
      shift ;;
    *)
      __print_help
      shift ;;
  esac
else
  __print_help
fi
