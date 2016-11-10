#!/bin/bash -e

local api_test_sleep_time=1
local api_test_time_taken=0

test_api_endpoint() {
  __process_msg "Testing API endpoint to determine API status"

  local api_url=$(cat $STATE_FILE | jq -r '.systemSettings.apiUrl')

  if [ $api_test_time_taken -lt $API_TIMEOUT ]; then
    if [ $api_test_sleep_time -eq 64 ]; then
      api_test_sleep_time=2;
    else
      api_test_sleep_time=$(( $api_test_sleep_time * 2 ))
    fi
  else
    __process_msg "API timeout exceeded. Unable to connect to API."
    exit
  fi

  api_response=$(curl -s -o /dev/null -w "%{http_code}" $api_url) || true

  if [ "$api_response" == "200" ]; then
    __process_msg "API is up and running proceeding with other steps"
  else
    __process_msg "API not running, retrying in $api_test_sleep_time seconds"
    sleep $api_test_sleep_time
    api_test_time_taken=$(( $api_test_time_taken + $api_test_sleep_time ))
    test_api_endpoint
  fi
}

main() {
  test_api_endpoint
}

main
