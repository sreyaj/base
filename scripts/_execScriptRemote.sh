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
  eval "$remote_cmd"
  local ret_code=$?
  if [ $ret_code -ne 0 ]; then
    echo "ERROR: remote command failed on host: $host"
    echo $remote_cmd_exec
    exit 1
  else
    echo "Remote command successful on host: $host"
    echo "$remote_cmd_exec"
  fi
}


