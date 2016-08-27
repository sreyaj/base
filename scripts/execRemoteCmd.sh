#!/bin/bash -e

## syntax for calling this function
## exec_remote_cmd "user" "192.156.6.4" "key" "ls -al"
exec_remote_cmd() {
  local user="$1"
  local host="$2"
  local key="$3"
  local cmd="$4"

  echo "executing $cmd on $host"
}
