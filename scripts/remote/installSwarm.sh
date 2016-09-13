#!/bin/bash -e

pull_swarm_image() {
  echo "Pulling swarm image..."
  docker pull library/swarm:latest
}

main() {
  pull_swarm_image
}

main
