#!/bin/bash -e

local EXISTING_SYSTEM_MACHINE_IMAGES=""

get_available_systemMachineImages() {
  __process_msg "GET-ing available system machine images from db"

  local api_token=$(cat $STATE_FILE | jq -r '.systemSettings.serviceUserToken')
  local api_url=$(cat $STATE_FILE | jq -r '.systemSettings.apiUrl')
  local system_machine_images_endpoint="$api_url/systemMachineImages"

  local response=$(curl -H "Content-Type: application/json" -H \
    "Authorization: apiToken $api_token" \
    -X GET $system_machine_images_endpoint \
    --silent)

  EXISTING_SYSTEM_MACHINE_IMAGES=$(echo $response | jq '.')
}

update_exec_runsh_images() {
  __process_msg "Updating exec and runsh image tags in system machine images"

  local deploy_tag=$(cat $STATE_FILE | jq -r '.deployTag')
  local system_machine_images=$(cat $STATE_FILE | jq -r '.systemMachineImages')
  local system_machine_images_length=$(echo $system_machine_images | jq -r '. | length')

  #TODO: Add fields for execRepo and runshRepo in state files and use it from there
  local exec_image_repo="shipimg/mexec"
  local runSh_image_repo="shipimg/runsh"

  local exec_image="$exec_image_repo:$deploy_tag"
  local runSh_image="$runSh_image_repo:$deploy_tag"

  echo "Updating execImage to $exec_image in state file"
  echo "Updating runShImage to $runSh_image in state file"

  local updated_system_machine_images=$(cat $STATE_FILE | jq '[ .systemMachineImages | .[] | .execImage="'$exec_image'" | .runShImage="'$runSh_image'" ]')
  local update=$(cat $STATE_FILE | jq '.systemMachineImages = '"$updated_system_machine_images"'')
  _update_state "$update"
}

save_systemMachineImages(){
  __process_msg "Saving available system machine images into db"

  local api_token=$(cat $STATE_FILE | jq -r '.systemSettings.serviceUserToken')
  local api_url=$(cat $STATE_FILE | jq -r '.systemSettings.apiUrl')
  local system_machine_images_endpoint="$api_url/systemMachineImages"

  local system_machine_images=$(cat $STATE_FILE | jq -r '.systemMachineImages')
  local system_machine_images_length=$(echo $system_machine_images | jq -r '. | length')

  for i in $(seq 1 $system_machine_images_length); do
    local system_machine_image=$(echo $system_machine_images | jq '.['"$i-1"']')
    local system_machine_image_name=$(echo $system_machine_image | jq '.name')

    local system_machine_image_id=$(echo $EXISTING_SYSTEM_MACHINE_IMAGES | jq -r '.[] | select (.name=='"$system_machine_image_name"') | .id')

    if [ -z "$system_machine_image_id" ]; then
      local post_call_resp_code=$(curl -H "Content-Type: application/json" \
        -H "Authorization: apiToken $api_token" \
        -X POST -d "$system_machine_image" \
        $system_machine_images_endpoint \
        --write-out "%{http_code}\n" --output /dev/null)
      if [ "$post_call_resp_code" -gt "299" ]; then
        echo "Error inserting system machine image(status code $post_call_resp_code)"
      else
        echo "Sucessfully inserted system machine image: $system_machine_image_name"
      fi
    else
      local put_call_resp_code=$(curl -H "Content-Type: application/json" \
      -H "Authorization: apiToken $api_token" \
      -X PUT -d "$system_machine_image" $system_machine_images_endpoint/$system_machine_image_id \
      --write-out "%{http_code}\n" --silent --output /dev/null)
      if [ "$put_call_resp_code" -gt "299" ]; then
        echo "Error updating system machine image: $system_machine_image_name (status code $put_call_resp_code)"
      else
        __process_msg "Sucessfully updated system machine image: $system_machine_image_name"
      fi
    fi
  done
  __process_msg "Successfully saved system machine images"
}

main() {
  __process_marker "Configuring system machine images"
  get_available_systemMachineImages
  update_exec_runsh_images
  save_systemMachineImages
}

main
