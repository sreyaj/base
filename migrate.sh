#!/bin/bash -e

readonly ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly USR_DIR="$ROOT_DIR/usr"
OLD_STATE_FILE="$ROOT_DIR/data/state.json"
STATE_FILE_TEMPLATE="$USR_DIR/state.json.example"
STATE_FILE_MIGRATE="$USR_DIR/state.json.migrate"

copy_template() {
  echo "copying state.json template"
  cp -vr $STATE_FILE_TEMPLATE $STATE_FILE_MIGRATE
}

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
    touch $STATE_FILE_MIGRATE
    local pretty_state=$(echo $state_migrate | jq '.' | tee $STATE_FILE_MIGRATE)
  else
    echo "The old state.json file doesn't exist"
  fi
}

main() {
  copy_template
  update_release
  update_machines
  update_install_status
  migrate
}

main
