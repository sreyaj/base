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
export DEPLOY_TAG=""

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

use_latest_release() {
  __process_msg "Using latest release"


  local release_major_versions="[]"
  local release_minor_versions=""
  local release_patch_versions=""

  for filepath in $VERSIONS_DIR/*; do
    local filename=$(basename $filepath)
    local file_major_version=""
    if [[ $filename =~ ^v([0-9]).([0-9])([0-9])*.([0-9])([0-9])*.json$ ]]; then
      local file_major_version="${BASH_REMATCH[1]}"
      file_major_version=$(python -c "print int($file_major_version)")
      release_major_versions="$file_major_version,"
    fi
  done

  release_major_versions="["${release_major_versions::-1}"]"
  local release_major_versions_count=$(echo $release_major_versions | jq '. | length')
  local release_file_major_version=0
  for i in $(seq 1 $release_major_versions_count); do
    local major_version=$(echo $release_major_versions | jq -r '.['"$i-1"']')
    if [ $major_version -gt $release_file_major_version ]; then
      release_file_major_version=$major_version
    fi
  done

  for filepath in $VERSIONS_DIR/*; do
    local filename=$(basename $filepath)
    local file_minor_version=""
    if [[ $filename =~ ^v($release_file_major_version).([0-9])([0-9])*.([0-9])([0-9])*.json$ ]]; then
      local file_minor_version="${BASH_REMATCH[2]}${BASH_REMATCH[3]}"
      file_minor_version=$(python -c "print int($file_minor_version)")
      release_minor_versions="$file_minor_version,"
    fi
  done

  release_minor_versions="["${release_minor_versions::-1}"]"
  release_minor_versions_count=$(echo $release_minor_versions | jq '. | length')
  local release_file_minor_version=0
  for i in $(seq 1 $release_minor_versions_count); do
    local minor_version=$(echo $release_minor_versions | jq -r '.['"$i-1"']')
    if [ $minor_version -gt $release_file_minor_version ]; then
      release_file_minor_version=$minor_version
    fi
  done

  for filepath in $VERSIONS_DIR/*; do
    local filename=$(basename $filepath)
    local file_patch_version=""
    if [[ $filename =~ ^v($release_file_major_version).($release_file_minor_version).([0-9])([0-9])*.json$ ]]; then
      local file_patch_version="${BASH_REMATCH[3]}${BASH_REMATCH[4]}"
      file_patch_version=$(python -c "print int($file_patch_version)")
      release_patch_versions="$file_patch_version,"
    fi
  done

  release_patch_versions="["${release_patch_versions::-1}"]"
  release_patch_versions_count=$(echo $release_patch_versions | jq '. | length')
  local release_file_patch_version=0
  for i in $(seq 1 $release_patch_versions_count); do
    local patch_version=$(echo $release_patch_versions | jq -r '.['"$i-1"']')
    if [ $patch_version -gt $release_file_patch_version ]; then
      release_file_patch_version=$patch_version
    fi
  done

  local latest_release="v"$release_file_major_version"."$release_file_minor_version"."$release_file_patch_version
  __process_msg "Latest release version :: "$latest_release

  export RELEASE_VERSION=$latest_release
}

install() {
  __process_msg "Running installer steps"

  if [ -z "$DEPLOY_TAG" ]; then
    export DEPLOY_TAG=$RELEASE_VERSION-alpha
  fi

  source "$SCRIPTS_DIR/getConfigs.sh"
  local release_version=$(cat $STATE_FILE | jq -r '.release')
  readonly SCRIPT_DIR_REMOTE="/tmp/shippable/$release_version"
  export RELEASE_VERSION=$release_version

  source "$SCRIPTS_DIR/bootstrapMachines.sh"
  source "$SCRIPTS_DIR/installCore.sh"
  source "$SCRIPTS_DIR/bootstrapApp.sh"
  source "$SCRIPTS_DIR/provisionServices.sh"
}

install_release() {
  # parse release
  local deploy_tag="$1"
  if [[ $deploy_tag =~ ^v([0-9]).([0-9])([0-9])*.([0-9])([0-9])*.*$ ]]; then
    __process_msg "Valid release version, parsing"
    local major_version="${BASH_REMATCH[1]}"
    major_version=$(python -c "print int($major_version)")

    local minor_version="${BASH_REMATCH[2]}${BASH_REMATCH[3]}"
    minor_version=$(python -c "print int($minor_version)")

    local patch_version="${BASH_REMATCH[4]}${BASH_REMATCH[5]}"
    patch_version=$(python -c "print int($patch_version)")

    local release=$(printf \
      "v%d.%d.%d" \
      "$major_version" \
      "$minor_version" \
      "$patch_version")

    __process_msg "Parsed release number: $release"

    local release_file_path="$VERSIONS_DIR/$release".json
    if [ -f $release_file_path ]; then
      __process_msg "Release file found: $release_file_path"
      local install_mode=$(cat $STATE_FILE \
        | jq -r '.installMode')
      export INSTALL_MODE="$install_mode"

      __process_msg "Running installer for release $deploy_tag"

      export RELEASE_VERSION=$release
      export DEPLOY_TAG=$deploy_tag
      install
    else
      __process_msg "No release file found at : $release_file_path, exiting"
      exit 1
    fi
  else
    __process_msg "Invalid release provided, exiting"
    exit 1
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
        __check_dependencies
        release_version=$(cat $STATE_FILE \
          | jq -r '.release')
        export RELEASE_VERSION=$latest_release
        install_release $1
      fi
      ;;
    -i|--install)
      shift
      __process_marker "Booting shippable installer"
      __check_dependencies
      use_latest_release
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
