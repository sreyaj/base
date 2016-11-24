#!/bin/bash -e

readonly COMPONENT_REPOSITORY=$1
readonly DEPLOY_VERSION=$2

remove_old_images() {
  local all_images=$(sudo docker images)
  echo "$all_images" | while read -r line; do
    local image_repository=$(echo $line | awk '{print $1}')
    local image_tag=$(echo $line | awk '{print $2}')
    if [ "$image_repository" == "$COMPONENT_REPOSITORY" ]; then
      if [ "$image_tag" != "$DEPLOY_VERSION" ]; then
        echo $image
        local stale_image=$image_repository:$image_tag
        echo "Stale image found, removing : $stale_image"
        sudo docker rmi $stale_image || true
      fi
    fi
  done
}

main() {
  if [ -z "$DEPLOY_VERSION" ]; then
    echo "DEPLOY_VERSION env required to remove stale images"
    exit 1
  fi

  if [ -z "$COMPONENT_REPOSITORY" ]; then
    echo "COMPONENT_REPOSITORY env required to remove stale images"
    exit 1
  fi

  remove_old_images
}

main
