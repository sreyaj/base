#!/bin/bash -e

install_redis(){
	echo "installing redis"
	apt-get update && apt-get install -o Dpkg::Options::="--force-confold" --force-yes -y redis-server
}

main() {
	if [ ! -z "sudo service --status-all 2>&1 | grep redis-server" ]; then
    echo "Redis already installed, skipping."
    return
  fi
	install_redis
}

main