#!/bin/bash -e

install_log_rotate() {
  apt-get -y -q install wget logrotate
}

install_rabbitmq() {
  apt-get -y --force-yes install rabbitmq-server
}

configure_rabbitmq() {
  # Create config and enable admin
  echo -e "[ \n {rabbit, [ \n {loopback_users, []}, \n {heartbeat, 3600} \n ]} \n ]." >> /etc/rabbitmq/rabbitmq.config
  /usr/sbin/rabbitmq-plugins enable rabbitmq_management
}

start_rabbitmq() {
  # Start
  chown -R rabbitmq:rabbitmq /var/lib/rabbitmq/mnesia
  chown -R rabbitmq:rabbitmq /var/log/rabbitmq
  ulimit -n 65536
  service rabbitmq-server restart
}

main() {
  {
    check_rabbitmq=$(service --status-all 2>&1 | grep rabbitmq-server)
  } || {
    true
  }
  if [ ! -z "$check_rabbitmq" ]; then
    echo "RabbitMQ already installed, skipping."
    return
  fi

  pushd /tmp
  install_log_rotate
  install_rabbitmq
  configure_rabbitmq
  start_rabbitmq
  popd
}

main
