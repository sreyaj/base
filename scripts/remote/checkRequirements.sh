#!/bin/bash -e

##TODO: read these values from config
readonly MIN_MEM=2048
readonly MIN_HDD=30
readonly KERNEL_ARCH=64

check_64_bit() {
  echo 'Checking kernel'

  kernel=$(uname -m)

  # need a 64 bit kernel
  if [[ $kernel == *"$KERNEL_ARCH"* ]]; then
    echo "$KERNEL_ARCH bit kernel detected"
  else
    echo "ERROR: kernel must be ${KERNEL_ARCH}-bit to run docker"
    exit 1
  fi
  ## this has to be added because apt-get update was throwing this error
  ## http://askubuntu.com/questions/104160/method-driver-usr-lib-apt-methods-https-could-not-be-found-update-error
  apt-get -y install apt-transport-https
}

check_ram() {
  echo "Checking RAM"

  mem=$(free -m | grep "Mem:" | awk '{print $2}' || echo "")

  if [ -z "$mem" ]; then
    echo "Unable to determine RAM"
  else
    echo "Total RAM: $mem"

    if [ $mem -lt $MIN_MEM ]; then
      echo "ERROR: insufficient RAM"
      exit 1
    fi
  fi
}

check_hdd_space() {
  echo "Checking HDD"
  total_space=$(df --total | grep "total" | awk '{print $2}' || echo "")

  if [ -z "$total_space" ]; then
    echo "Unable to determine disk space"
  else
    let space_in_mb=total_space/1000
    let space_in_gb=space_in_mb/1000
    echo "Total HDD capacity is ${space_in_gb}GB"

    # numbers in GB
    if [ $space_in_gb -lt $MIN_HDD ]; then
      echo "ERROR: hard drive is too small to run builds. Please allow a minimum of ${MIN_HDD}GB"
      exit 1
    fi
  fi
}

main() {
  check_64_bit
  check_hdd_space
  check_ram
}

main
