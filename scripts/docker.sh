#!/bin/bash
# Examples:
#   ./docker.sh start
#   ./docker.sh stop

# 如果任何命令的退出状态码（返回值）不为零，那么整个脚本就会立即退出
set -e

CURRENT_DIR="$(
  cd "$(dirname "$0")"
  pwd -P
)"

cd "$CURRENT_DIR/../"

# 启动用户
check_run_user() {
  CURRENT_USER=$1

  if [ -z ${CURRENT_USER} ]; then
    # 目前目前当前用户
    CURRENT_USER=$(id -un)
  fi
  if ! id "${CURRENT_USER}" >/dev/null 2>&1; then
    echo "user '${CURRENT_USER}' does not exist"
    exit 1
  fi
  export CURRENT_USER_UID="$(id -u ${CURRENT_USER})"
  export CURRENT_USER_GID="$(id -g ${CURRENT_USER})"
  # 检查操作系统类型是否为 macOS（Darwin）
  if [[ "$OSTYPE" == "darwin"* ]]; then
    export CURRENT_USER_UID="1000"
    export CURRENT_USER_GID="1001"
  fi

}

check_run_user "$2"

case "$1" in
start)
  docker-compose -p local-env up -d
  ;;
stop)
  docker-compose -p local-env  stop
  ;;
down)
  docker-compose -p local-env down
  ;;
logs)
  docker-compose -p local-env logs
  ;;
*)
  echo $"Usage: $0 {start [run_user]|stop|down|logs}"
  exit 1
  ;;
esac
