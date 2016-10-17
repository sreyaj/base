#!/bin/bash -e

readonly ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly USR_DIR="$ROOT_DIR/usr"
OLD_STATE_FILE="$ROOT_DIR/data/state.json"
STATE_FILE_TEMPLATE="$USR_DIR/state.json.example"
STATE_FILE_MIGRATE="$USR_DIR/state.json.migrate"

update_release() {
  # update the release version in migrate from versions file
  echo "updating release version and main metadata"
  echo "updating install mode to production"
  local update=$(cat $STATE_FILE_MIGRATE \
    | jq '.installMode="production"')
  update=$(echo $update \
    | jq '.' \
    | tee $STATE_FILE_MIGRATE)
}

update_machines() {
  # copy machines from old state to migrate file
  echo "updating machines"
  cp -vr $ROOT_DIR/data/machines.json $USR_DIR/machines.json
  local machines=$(cat $OLD_STATE_FILE \
    | jq -c '[ .machines[] ]')

  local update=$(cat $STATE_FILE_MIGRATE \
    | jq '.machines='$machines'' )

  update=$(echo $update \
    | jq '.' \
    | tee $STATE_FILE_MIGRATE)
}

update_install_status() {
  # update install status of all settings to true
  echo "updating install status"
  local update=$(cat $STATE_FILE_MIGRATE \
    | jq '.installStatus.dockerInstalled=true')
  update=$(echo $update \
    | jq '.installStatus.dockerInitialized=true')
  update=$(echo $update \
    | jq '.installStatus.redisInstalled=true')
  update=$(echo $update \
    | jq '.installStatus.redisInitialized=true')
  update=$(echo $update \
    | jq '.installStatus.databaseInstalled=true')
  update=$(echo $update \
    | jq '.installStatus.databaseInitialized=true')
  update=$(echo $update \
    | jq '.installStatus.rabbitmqInstalled=true')
  update=$(echo $update \
    | jq '.installStatus.rabbitmqInitialized=true')
  update=$(echo $update \
    | jq '.installStatus.vaultInstalled=true')
  update=$(echo $update \
    | jq '.installStatus.vaultInitialized=true')
  update=$(echo $update \
    | jq '.installStatus.serviceuserTokenGenerated=true')
  update=$(echo $update \
    | jq '.installStatus.systemConfigUpdated=true')
  update=$(echo $update \
    | jq '.installStatus.machinesBootstrapped=true')
  update=$(echo $update \
    | jq '.installStatus.machinesSSHSuccessful=true')
  update=$(echo $update \
    | jq '.installStatus.gitlabInstalled=true')
  update=$(echo $update \
    | jq '.installStatus.gitlabInitialized=true')
  update=$(echo $update \
    | jq '.installStatus.composeInstalled=true')
  update=$(echo $update \
    | jq '.installStatus.swarmInstalled=true')
  update=$(echo $update \
    | jq '.installStatus.swarmInitialized=true')
  update=$(echo $update \
    | jq '.installStatus.ecrInitialized=true')
  update=$(echo $update \
    | jq '.installStatus.ecrInstalled=true')

  update=$(echo $update \
    | jq '.' \
    | tee $STATE_FILE_MIGRATE)
}


migrate() {
  echo "migrating integrations"
  if [ -f $OLD_STATE_FILE ]; then
    #cp $OLD_STATE_FILE $STATE_FILE_MIGRATE
    local sys_ints=$(cat $OLD_STATE_FILE | jq -c '[ .systemIntegrations[] ]')
    local sys_ints_length=$(echo $sys_ints | jq ' . | length')
    local system_settings=$(cat $OLD_STATE_FILE | jq -c '.systemSettings')
    local master_ints="[]"
    for i in $(seq 1 $sys_ints_length); do
      local master_type=$(echo $sys_ints | jq '.['"$i-1"'] | .masterType')
      local master_name=$(echo $sys_ints | jq '.['"$i-1"'] | .masterName')
      if [ "$master_name" == "\"ECR\"" ]; then
        master_type="\"cloudproviders\""
        master_name="\"AWS\""
        local access_key=$(echo $sys_ints | jq -r '.['"$i-1"'] | .formJSONValues[] | select (.label=="aws_access_key_id") | .value')
        local secret_key=$(echo $sys_ints | jq -r '.['"$i-1"'] | .formJSONValues[] | select (.label=="aws_secret_access_key") | .value')
        local formJSONValues="[
        {
          \"label\":\"accessKey\",
          \"value\":\"$access_key\"
        },
        {
          \"label\":\"secretKey\",
          \"value\":\"$secret_key\"
        }]"
        formJSONValues=$(echo $formJSONValues | jq -c '.')
        sys_ints=$(echo $sys_ints | jq 'map((select(.masterName == "ECR") | .masterName) |= "AWS")')
        sys_ints=$(echo $sys_ints | jq 'map((select(.masterName == "AWS") | .masterType) |= "cloudproviders")')
        sys_ints=$(echo $sys_ints | jq 'map((select(.masterName == "AWS") | .formJSONValues) |= '$formJSONValues')')

      fi
      if [ "$master_name" == "\"hub\"" ]; then
        master_name="\"Docker\""
        sys_ints=$(echo $sys_ints | jq 'map((select(.masterName == "hub") | .masterName) |= "Docker")')
      fi
      local master_int=$(echo $master_ints | jq '.[] | select (.name=='$master_name') | .name')
      if [ -z "$master_int" ]; then
        master_ints=$(echo $master_ints | jq '
        . |= . + [{
          "name": '"$master_name"',
          "type": '"$master_type"'
        }]')
      fi
    done
    system_settings=$(echo $system_settings | jq '.systemImagesRegistry ="374168611083.dkr.ecr.us-east-1.amazonaws.com"')
    system_settings=$(echo $system_settings | jq '.stepExecImage ="shipimg/micro50:stepExec"')
    system_settings=$(echo $system_settings | jq '.customHostDockerVersion ="1.12.1"')
    local state_migrate="{
      \"masterIntegrations\": $master_ints,
      \"systemIntegrations\": $sys_ints,
      \"systemSettings\": $system_settings,
      \"release\": \"\",
      \"services\":[]
    }"

    local pretty_state=$(echo $state_migrate \
      | jq '.' \
      | tee $STATE_FILE_MIGRATE)
  else
    echo "The old state.json file doesn't exist"
  fi
}

update_db_creds() {
  echo "updating db credentials"
  local db_host=$(cat $STATE_FILE_MIGRATE \
    | jq '.machines[] | select (.group=="core" and .name=="db")')
  local host=$(echo $db_host | jq -r '.ip')

  local update=$(cat $STATE_FILE_MIGRATE \
    | jq '.systemSettings.dbHost="'$host'"')
  update=$(echo $update \
    | jq '.systemSettings.dbPort=5432')
  update=$(echo $update \
    | jq '.systemSettings.dbUsername="apiuser"')
  update=$(echo $update \
    | jq '.systemSettings.dbPassword="testing1234"')
  update=$(echo $update \
    | jq '.systemSettings.dbname="shipdb"')
  update=$(echo $update \
    | jq '.systemSettings.dbDialect="postgres"')
  local db_url="$host:5432"
  update=$(echo $update \
    | jq '.systemSettings.dbUrl="'$db_url'"')

  update=$(echo $update \
    | jq '.' \
    | tee $STATE_FILE_MIGRATE)
}

update_amqp_vars() {
  echo "updating amqp vars"
  local amqp_user="SHIPPABLETESTUSER"
  local amqp_pass="SHIPPABLETESTPASS"
  local amqp_protocol=$(cat $STATE_FILE_MIGRATE \
    | jq -r '.systemSettings.amqpProtocol')
  local amqp_host=$(cat $STATE_FILE_MIGRATE \
    | jq -r '.systemSettings.amqpHost')
  local amqp_port=$(cat $STATE_FILE_MIGRATE \
    | jq -r '.systemSettings.amqpPort')
  local amqp_admin_protocol=$(cat $STATE_FILE_MIGRATE \
    | jq -r '.systemSettings.amqpAdminProtocol')
  local amqp_admin_port=$(cat $STATE_FILE_MIGRATE \
    | jq -r '.systemSettings.amqpAdminPort')

  local amqp_url_updated="$amqp_protocol://$amqp_user:$amqp_pass@$amqp_host/shippable"
  local amqp_url_root="$amqp_protocol://$amqp_user:$amqp_pass@$amqp_host/shippableRoot"
  local amqp_url_admin="$amqp_admin_protocol://$amqp_user:$amqp_pass@$amqp_host:$amqp_admin_port"

  local update=$(cat $STATE_FILE_MIGRATE \
    | jq '.systemSettings.amqpUrl="'$amqp_url_updated'"')
  update=$(echo $update \
    | jq '.systemSettings.amqpUrlRoot="'$amqp_url_root'"')
  update=$(echo $update \
    | jq '.systemSettings.amqpUrlAdmin="'$amqp_url_admin'"')
  update=$(echo $update \
    | jq '.systemSettings.amqpDefaultExchange="shippableEx"')

  update=$(echo $update \
    | jq '.' \
    | tee $STATE_FILE_MIGRATE)
}

copy_keys() {
  echo "copying key files"
  sudo cp -vr $ROOT_DIR/data/machinekey $USR_DIR/machinekey
  sudo cp -vr $ROOT_DIR/data/machinekey.pub $USR_DIR/machinekey.pub
}

main() {
  migrate
  update_release
  update_machines
  update_install_status
  update_db_creds
  copy_keys
  update_amqp_vars
}

main
