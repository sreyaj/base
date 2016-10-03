#!/bin/bash -e

install_redis() {
  echo "installing redis"
  apt-get install -o Dpkg::Options::="--force-confold" --force-yes -y redis-server
}

main() {
  {
    check_redis=$(service --status-all 2>&1 | grep redis-server)
  } || {
    true
  }
  if [ ! -z "$check_redis" ]; then
    echo "Redis already installed, skipping."
    return
  fi

  install_redis
}

main
