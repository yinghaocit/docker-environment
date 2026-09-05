# ddmj 开发环境 — 三合一容器 (laravel-rest-api + web-admin + app/h5)
# 用法:
#   docker build -t local/ddmj-dev:1.0.0 .
#   docker run --name ddmj -p 9000:9000 -p 3001:3001 -p 3002:3002 \
#     -v /Volumes/DevWorkspace/Projects/ddmj:/var/www \
#     local/ddmj-dev:1.0.0
#
# 端口说明:
#   9000 = PHP-FPM (Laravel API)
#   3001 = web-admin vite dev server
#   3002 = app uni-app h5 dev server

FROM php:8.3-fpm

LABEL maintainer="ddmj-dev"

ENV COMPOSER_ALLOW_SUPERUSER=1
ENV APP_DIR=/var/www

# ---- 系统依赖 ----
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    git curl unzip rsync libicu-dev libonig-dev libxml2-dev \
    libsqlite3-dev libfreetype6-dev libpng-dev libjpeg62-turbo-dev \
    supervisor \
  && rm -rf /var/lib/apt/lists/*

# ---- PHP 扩展 ----
RUN docker-php-ext-install bcmath intl pdo_mysql opcache gd
# pcntl (queue worker 需要)
RUN docker-php-ext-install pcntl

# opcache 开发配置
RUN { \
      echo "opcache.enable=1"; \
      echo "opcache.file_cache=/tmp/opcache"; \
      echo "opcache.validate_timestamps=1"; \
      echo "opcache.revalidate_freq=0"; \
    } > /usr/local/etc/php/conf.d/opcache-dev.ini

# ---- Node.js 20 LTS (web-admin + uni-app h5) ----
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
  && apt-get install -y --no-install-recommends nodejs \
  && rm -rf /var/lib/apt/lists/*

# ---- Composer ----
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# ---- 工作目录结构 ----
# 挂载点: /var/www/{laravel-rest-api, web-admin, app}
RUN mkdir -p /var/www/laravel-rest-api /var/www/web-admin /var/www/app \
             /var/log/supervisor

COPY supervisor.conf /etc/supervisor/conf.d/ddmj.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 9000 3001 3002

ENTRYPOINT ["/entrypoint.sh"]
