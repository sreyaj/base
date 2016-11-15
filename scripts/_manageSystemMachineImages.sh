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

save_systemMachineImages(){
  __process_msg "Saving available system machine images into db"

  local api_token=$(cat $STATE_FILE | jq -r '.systemSettings.serviceUserToken')
  local api_url=$(cat $STATE_FILE | jq -r '.systemSettings.apiUrl')
  local system_machine_images_endpoint="$api_url/systemMachineImages"

  local system_machine_images=$(cat $STATE_FILE | jq -r '.systemMachineImages')
  local system_machine_images_length=$(echo $system_machine_images | jq -r '. | length')

  for i in $(seq 1 $system_machine_images_length); do
    local system_machine_image=$(echo $system_machine_images | jq '.['"$i-1"']')
    local system_machine_image_name=$(echo $system_machine_image | jq -r '.name')

    local system_machine_image_id=$(echo $EXISTING_SYSTEM_MACHINE_IMAGES | jq -r '.[] | select (.name="$system_machine_image_name") | .id')

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
  save_systemMachineImages
}

main
