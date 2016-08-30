#!/bin/bash -e

## syntax for calling this function
## exec_remote_cmd "user" "192.156.6.4" "key" "ls -al"
_exec_remote_cmd() {
  local user="$SSH_USER"
  local key="$SSH_PRIVATE_KEY"
  local timeout=10
  local port=22

  local host="$1"
  shift
  local cmd="$@"

  local remote_cmd="ssh -q \
    -o StrictHostKeyChecking=no \
    -o NumberOfPasswordPrompts=0 \
    -o ConnectTimeout=$timeout \
    -p $port \
    -i $key \
    $user@$host \
    $cmd"

  {
    __process_msg "Executing $cmd on host: $host" && eval "$remote_cmd"
  } || {
    __process_msg "ERROR: Remote command $cmd failed on host: $host"
    exit 1
  }
}
