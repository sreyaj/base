#!/bin/bash -e


main() {
  __process_marker "Configuring services list"

  #TODO:
  # find list of all enabled master integrations
  # find the list of servics from integration services in versions file for each master integration
  # take unique list of servics from the list
  # add placeholder objects in statefile:services[] array
  # DO NOT start or configure services, that will be done in next step
}

main
