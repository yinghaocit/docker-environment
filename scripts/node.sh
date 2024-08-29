#!/bin/bash
# Example: 
#   ./node.sh npm install
#   ./node.sh npm run build

CURRENT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"

. $CURRENT_DIR/.common_func

check_env_file

# Check if runing in tty
is_tty="" && [ -t 1 ] && is_tty="-t"

docker run --rm -i ${is_tty} \
    --volume "$CURRENT_DIR/../../$NODE_FOLDER_PATH":/app \
    --workdir /app \
    --user $(id -u):$(id -g) \
    ciandtchina/node:10-build-tools "$@"
