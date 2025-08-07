#!/bin/bash

# 获取主机用户id (修复语法错误)
USER_ID=$(id -u)
GROUP_ID=$(id -g)

# 如果无法获取用户ID，使用默认值
USER_ID=${USER_ID:-1000}
GROUP_ID=${GROUP_ID:-1000}

# 给主机用户授权指定的挂载目录
chown -R $USER_ID:$GROUP_ID /var/www/html

# 创建和主机用户相同uid的用户，名为docker
if ! id "docker" &>/dev/null; then
    useradd --shell /bin/bash -u $USER_ID -g $GROUP_ID -o -c "" -m docker
    usermod -a -G root docker
fi

export HOME=/home/docker

exec /usr/local/bin/gosu docker "$@"
