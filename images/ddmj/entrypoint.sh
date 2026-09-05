#!/bin/bash
set -e

# 获取宿主机用户 UID，确保挂载目录权限正确
HOST_UID=$(id -u)
HOST_GID=$(id -g)

# 创建与宿主机相同 UID 的用户 (非 root 运行 node/composer)
if ! id -u user &>/dev/null; then
    useradd --shell /bin/bash -u $HOST_UID -o -c "" -m user
fi
chown -R user:user /var/www/laravel-rest-api /var/www/web-admin /var/www/app 2>/dev/null || true

# Laravel: 首次启动自动安装依赖 + 生成 key
cd /var/www/laravel-rest-api
if [ ! -d "vendor" ]; then
    echo "[entrypoint] Running composer install for laravel-rest-api..."
    su user -c "composer install --no-interaction --prefer-dist"
fi
if [ ! -f ".env" ] && [ -f ".env.example" ]; then
    cp .env.example .env
    chown user:user .env
fi
su user -c "php artisan key:generate --force" 2>/dev/null || true

# web-admin: 首次启动自动安装依赖
cd /var/www/web-admin
if [ ! -d "node_modules" ]; then
    echo "[entrypoint] Running npm install for web-admin..."
    su user -c "npm install --legacy-peer-deps"
fi

# app (uni-app h5): 首次启动自动安装依赖
cd /var/www/app
if [ ! -d "node_modules" ]; then
    echo "[entrypoint] Running npm install for app..."
    su user -c "npm install --legacy-peer-deps"
fi

echo "[entrypoint] Starting services..."
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
