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
export INSTALL_MODE="local"
readonly IFS=$'\n\t'
readonly ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly VERSIONS_DIR="$ROOT_DIR/versions"
readonly MIGRATIONS_DIR="$ROOT_DIR/migrations"
readonly SCRIPTS_DIR="$ROOT_DIR/scripts"
readonly USR_DIR="$ROOT_DIR/usr"
readonly REMOTE_SCRIPTS_DIR="$ROOT_DIR/scripts/remote"
readonly LOCAL_SCRIPTS_DIR="$ROOT_DIR/scripts/local"
readonly STATE_FILE="$USR_DIR/state.json"
readonly STATE_FILE_BACKUP="$USR_DIR/state.json.backup"
readonly SSH_USER="root"
readonly SSH_PRIVATE_KEY=$USR_DIR/machinekey
readonly SSH_PUBLIC_KEY=$USR_DIR/machinekey.pub
readonly LOCAL_BRIDGE_IP=172.17.42.1
export LC_ALL=C
export RELEASE_VERSION=""

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
  source "$SCRIPTS_DIR/getConfigs.sh"
  local release_version=$(cat $STATE_FILE | jq -r '.release')
  readonly RELEASE_VERSION=$release_version
  readonly SCRIPT_DIR_REMOTE="/tmp/shippable/$release_version"

  source "$SCRIPTS_DIR/bootstrapMachines.sh"
  source "$SCRIPTS_DIR/installCore.sh"
  source "$SCRIPTS_DIR/bootstrapApp.sh"
  source "$SCRIPTS_DIR/provisionServices.sh"
}

install_release() {
  local release=$1
  local release_file="$VERSIONS_DIR/$release".json
  if [ -f $release_file ]; then
    type jq
    __process_marker "Booting shippable installer"
    local install_mode=$(cat $STATE_FILE | jq -r '.installMode')
    local release=$1
    local update=$(cat $STATE_FILE | jq '.release="'$release'"')
    _update_state "$update"
    if [ "$install_mode" == "production" ] || [ "$install_mode" == "local" ]; then
      export INSTALL_MODE="$install_mode"
    else
      __process_msg "Running installer in default 'local' mode"
    fi
    install
  else
    __process_msg "Invalid release version $release"
  fi
}

install_file() {
  local state_file=$1
  if [ -f $state_file ]; then
    type jq
    local copy=$(cp $state_file $STATE_FILE 2> /dev/null)
    __process_marker "Booting shippable installer"
    local install_mode=$(cat $STATE_FILE | jq -r '.installMode')
    if [ "$install_mode" == "production" ] || [ "$install_mode" == "local" ]; then
      export INSTALL_MODE="$install_mode"
    else
      __process_msg "Running installer in default 'local' mode"
    fi
    install
  else
    __process_msg "$state_file not present."
  fi
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
    -r | --release    Install a particular version
    -f | --file       Use existing state file
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
    -f|--file)
      shift
      if [[ ! $# -eq 1 ]]; then
        __process_msg "Specify the state file to be used for install."
      else
        install_file $1
      fi
      ;;
    -r|--release)
      shift
      if [[ ! $# -eq 1 ]]; then
        __process_msg "Mention the release version to be installed."
      else
        install_release $1
      fi
      ;;
    -i|--install)
      shift
      __process_marker "Booting shippable installer"
      if [[ $# -eq 1 ]]; then
        install_mode=$1
      fi
      if [ "$install_mode" == "production" ] || [ "$install_mode" == "local" ]; then
        export INSTALL_MODE="$install_mode"
        install
      else
        __process_msg "Running installer in default 'local' mode"
        install
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
