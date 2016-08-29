#!/bin/bash -e

_copy_remote() {
  local user="$SSH_USER"
  local key="$SSH_PRIVATE_KEY"
  local port=22
  local host="$1"
  shift
  local source_path="$1"
  local path_source="$source_path"
  shift
  local dest_path="$1"
  local path_dest="$dest_path"

  echo "copying $path_source to remote host: $path_dest"
  remove_key_cmd="ssh-keygen -q -f '$HOME/.ssh/known_hosts' -R $host"
  {
    eval $remove_key_cmd
  } || {
    true
  }

  _exec_remote_cmd $host "mkdir -p $REMOTE_DIR"
  copy_cmd="rsync -q -avz -e \
    'ssh -q \
      -o StrictHostKeyChecking=no \
      -o NumberOfPasswordPrompts=0 \
      -p $port \
      -i $SSH_PRIVATE_KEY \
      -C -c blowfish' \
      $path_source $user@$host:$path_dest"

  copy_cmd_out=$(eval $copy_cmd)
  echo "$path_dest"
}
