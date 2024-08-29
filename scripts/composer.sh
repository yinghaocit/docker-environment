#!/bin/bash
CURRENT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
HOST_APP_PATH="$CURRENT_DIR/../../source"

. $CURRENT_DIR/.common_func
cd "$CURRENT_DIR/../"

check_env_file

# Check if runing in tty
is_tty="" && [ -t 1 ] && is_tty="-t"

docker exec -i ${is_tty} \
    --user docker \
    --workdir /var/www/html/ \
    "${PROJECT_KEY}-web-server" composer "$@"
