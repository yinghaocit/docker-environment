#!/bin/bash

# Load the docker alias variables
CURRENT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"

. $CURRENT_DIR/.common_func

check_env_file

# Flush memcache
docker exec $(docker-compose ps -q memcached) bash -c "echo flush_all > /dev/tcp/127.0.0.1/11211"

# Flush varnish
docker exec $(docker-compose ps -q varnish) sh -c 'varnishadm "ban req.http.host ~ ."'
