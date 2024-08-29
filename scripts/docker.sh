#!/bin/bash
# Examples:
#   ./docker.sh start root
#   ./docker.sh stop
set -e

CURRENT_DIR="/home/lctnmee/Documents/project/docker-environment"

. $CURRENT_DIR/scripts/.common_func

cd "$CURRENT_DIR"

# Check runing user
check_run_user() {
  CURRENT_USER=$1
  if [ -z ${CURRENT_USER} ]; then
    CURRENT_USER=$(id -un)
  fi
  if ! id "${CURRENT_USER}" >/dev/null 2>&1; then
    echo "user '${CURRENT_USER}' does not exist"
    exit 1
  fi
  export CURRENT_USER_UID="$(id -u ${CURRENT_USER})"
  export CURRENT_USER_GID="$(id -g ${CURRENT_USER})"
  if [[ "$OSTYPE" == "darwin"* ]]; then
    export CURRENT_USER_UID="1000"
    export CURRENT_USER_GID="1001"
  fi
}

create_docker_network() {
  NETWORK="${PROJECT_KEY}-default-network"
  if [ -z "$(docker network ls | grep "${NETWORK}")" ]; then
    docker network create --subnet 10.19.0.0/16 -d bridge ${NETWORK}
  fi
}

check_run_user "$2"
case "$1" in
  start)
    check_env_file
    create_docker_network
    docker-compose up -d
    ;;
  stop)
    docker-compose stop
    ;;
  down)
    docker-compose down
    ;;
  logs)
    docker-compose logs
    ;;
  *)
    echo $"Usage: $0 {start [run_user]|stop|down|logs}"
    exit 1
    ;;
esac
