#!/bin/bash -e


pull_swarm_image() {
  echo "pulling swarm image"
  sudo docker pull library/swarm:latest
}

main() {
  pull_swarm_image
}

main
