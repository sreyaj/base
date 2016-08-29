#!/bin/bash -e

##TODO: read this from global config
readonly PG_VERSION=9.5
readonly PG_USER=postgres
readonly PG_DEFAULT_CONFIG_PATH=/etc/postgresql/$PG_VERSION/main
readonly PG_CONFIG_PATH=$PG_DEFAULT_CONFIG_PATH/postgresql.conf
readonly PG_BIN_PATH=/usr/lib/postgresql/$PG_VERSION/bin

readonly ROOT_MOUNT_PATH=/pg
readonly ROOT_DB_PATH="$ROOT_MOUNT_PATH"/db
readonly ROOT_CONFIG_PATH="$ROOT_MOUNT_PATH"/config

readonly DATA_MOUNT_PATH=/ship
readonly DATA_DB_PATH="$DATA_MOUNT_PATH"/db

readonly DB_NAME=shipdb
readonly DB_ROLE=dbo
readonly DB_USER=apiuser
readonly DB_USER_PASS=testing1234
readonly DB_TABLESPACE_PATH=/ship/db
readonly DB_TABLESPACE_NAME=shipts

install_postgres() {
  echo "Checking existing Postgres installation"
  local pg_path=""
  {
    pg_path=$(which psql)
  } || {
    pg_path=""
  }

  if [ -z "$pg_path" ]; then
    echo "|_########## Postgres not installed, installing"
    echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | sudo tee -a /etc/apt/sources.list.d/pgdg.list
    wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -

    sudo apt-get update -y
    sudo apt-get install -y postgresql postgresql-contrib

  else
    echo "|_########## Postgres already installed, skipping"
  fi

}

__create_filesystem() {
  local mount_point="$1"
  echo "|_########## Creating filesystem from mount $mount_point"
  sudo mkfs.ext4 "$mount_point"
}

__mount_filesystem() {
  local mount_point="$1"
  local mount_path="$2"
  echo "|_########## Mounting new filesystem to $mount_path"
  sudo mkdir -p "$mount_path"
  echo "$mount_point $mount_path auto noatime 0 0" | sudo tee -a /etc/fstab
  sudo mount "$mount_path"
}

configure_data_dirs() {
  echo "Configuring Postgres data directory"
  sudo mkdir -p $ROOT_MOUNT_PATH

  echo "Configuring Shippable data directory"
  sudo mkdir -p $DATA_MOUNT_PATH
}

update_ownership() {
  echo "Updating ownership of Postgres data directory"
  sudo chown -cR $PG_USER:$PG_USER $ROOT_MOUNT_PATH

  echo "Updating ownership of Shippable data directory"
  sudo chown -cR $PG_USER:$PG_USER $DATA_MOUNT_PATH
}

initialize_root_db() {
  echo "Initializing root DB"
  sudo -u postgres mkdir -p $ROOT_DB_PATH
  sudo -u postgres mkdir -p $ROOT_CONFIG_PATH
  local init_db_cmd="sudo -u postgres $PG_BIN_PATH/initdb $ROOT_DB_PATH"
  echo "|_######### executing $init_db_cmd"
  init_db_cmd_res=$($init_db_cmd)
}

initialize_data_db_directory() {
  echo "Initializing  data DB"
  sudo -u postgres mkdir -p $DATA_DB_PATH
  #local init_db_cmd="sudo -u postgres $PG_BIN_PATH/initdb $DATA_DB_PATH"
  #echo "|_######### executing $init_db_cmd"
  #init_db_cmd_res=$($init_db_cmd)
}


stop_running_instance() {
  echo "Stopping running Postgres instance"
  {
    sudo service postgresql stop
  } || {
    echo "Service already stopped"
  }
}

create_root_config_files() {
  echo "Creating root config files"
  ##
  # These are just copied over from the default installation
  # and need to be checked out from SCM
  ##
  sudo cp -vr $PG_DEFAULT_CONFIG_PATH/pg_hba.conf $ROOT_CONFIG_PATH/pg_hba.conf
  sudo cp -vr $PG_DEFAULT_CONFIG_PATH/pg_ident.conf $ROOT_CONFIG_PATH/pg_ident.conf
}

update_root_config() {
  echo "Updating root database path to : $ROOT_DB_PATH"
  echo "data_directory = '$ROOT_DB_PATH'" | sudo tee -a $PG_CONFIG_PATH

  echo "Updating hba file path to : $ROOT_CONFIG_PATH/pg_hba.conf"
  echo "hba_file = '$ROOT_CONFIG_PATH/pg_hba.conf'"  | sudo tee -a $PG_CONFIG_PATH

  echo "Updating ident file path to : $ROOT_CONFIG_PATH/pg_ident.conf"
  echo "ident_file = '$ROOT_CONFIG_PATH/pg_ident.conf'"  | sudo tee -a $PG_CONFIG_PATH

  sudo chown -cR postgres:postgres $ROOT_CONFIG_PATH
}

initialize_custom_config() {
  local header="Shippable Postgres"
  {
    grep "$header" $PG_CONFIG_PATH
  } || {
    echo "#------------------------------------------------------" | sudo tee -a $PG_CONFIG_PATH
    echo "#----------- Shippable Postgres Config ----------------" | sudo tee -a $PG_CONFIG_PATH
    echo "#------------------------------------------------------" | sudo tee -a $PG_CONFIG_PATH
  }
  #################################################################
  ######### SHIPPABLE custom POSTGRES configuration ###############
  ######### add variables here that will override defaults in #####
  ######### /etc/postgresql/9.5/main/postgresql.conf ##############
  #################################################################
  echo "listen_addresses='*'"  | sudo tee -a $PG_CONFIG_PATH
}

initialize_auth_config() {
  local hba_config=$ROOT_CONFIG_PATH/pg_hba.conf
  local header="Shippable Postgres"
  {
    grep "$header" $hba_config
  } || {
    echo "#------------------------------------------------------" | sudo tee -a $hba_config
    echo "#----------- Shippable Postgres Config ----------------" | sudo tee -a $hba_config
    echo "#------------------------------------------------------" | sudo tee -a $hba_config
  }
  #################################################################
  ######### SHIPPABLE custom POSTGRES configuration ###############
  ######### add variables here that will override defaults in #####
  ######### /pg/config/pg_hba.conf ################################
  #################################################################
  echo "host all  all    0.0.0.0/0  md5" | sudo tee -a $hba_config
}

start_instance() {
  echo "Starting Postgres"
  sudo service postgresql start
}

bootstrap_db() {
  sudo -u postgres psql -c "CREATE ROLE $DB_ROLE INHERIT";
  sudo -u postgres psql -c "CREATE USER $DB_USER IN ROLE $DB_ROLE PASSWORD '$DB_USER_PASS' LOGIN INHERIT";
  sudo -u postgres psql -c "CREATE TABLESPACE $DB_TABLESPACE_NAME OWNER $DB_ROLE LOCATION '$DB_TABLESPACE_PATH'";
  sudo -u postgres psql -c "CREATE DATABASE $DB_NAME OWNER $DB_ROLE TABLESPACE $DB_TABLESPACE_NAME";
  sudo -u postgres psql -c "REVOKE CONNECT ON DATABASE $DB_NAME FROM PUBLIC";
  sudo -u postgres psql -c "GRANT CONNECT ON DATABASE $DB_NAME TO $DB_ROLE";
}

main() {
  if [ ! -z "sudo service --status-all 2>&1 | grep postgres" ]; then
    echo "Postgres already installed, skipping."
    return
  fi

  install_postgres
  configure_data_dirs
  update_ownership
  initialize_root_db
  initialize_data_db_directory
  stop_running_instance
  create_root_config_files
  update_root_config
  initialize_custom_config
  initialize_auth_config
  start_instance
  sleep 5
  bootstrap_db
}

main
