#!/bin/bash

# Create nginx config directory
function create_nginx () {
  if [ ! -d /etc/nginx ]; then
    sudo mkdir -p /etc/nginx
  fi
}

# Create nginx logs directory
function create_logs () {
  if [ ! -d /var/log/nginx ]; then
    sudo mkdir -p /var/log/nginx
  fi
}

# Populate /etc/nginx
function populate_nginx () {
  OPENRESTY_IMAGE='lomotif/openresty'
  OPENRESTY_IMAGE_PATTERN="\b${OPENRESTY_IMAGE}\b"
  if [ -z "$(sudo docker images | grep -E ${OPENRESTY_IMAGE_PATTERN})" ]; then
    echo "${OPENRESTY_IMAGE} image not found. Cannot run"
    exit 1
  fi

  CONTAINER_ID=$(sudo docker run -d "${OPENRESTY_IMAGE}")
  sudo docker cp "${CONTAINER_ID}":/etc/nginx /tmp/nginx_${CONTAINER_ID}

  create_nginx

  sudo cp -R /tmp/nginx_${CONTAINER_ID}/* /etc/nginx/ && \
  sudo rm -r /tmp/nginx_${CONTAINER_ID}

  sudo docker stop ${CONTAINER_ID} && \
  sudo docker rm ${CONTAINER_ID}

  echo "Populated /etc/nginx"
  exit 0
}


case "$1" in
  nginx)
    create_nginx
    ;;

  logs)
    create_logs
    ;;

  populate_nginx)
    populate_nginx
    ;;

  *)
    echo 'Usage: bootstrap create_nginx|create_logs|populate_nginx'
    exit 1
esac



