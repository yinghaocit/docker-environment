# 精简修正版 dev 镜像 — 基于 ciandtchina/drupal-web (Debian 11 bullseye)
# 相对原 images/php8.3-apache-devpack/Dockerfile 的改动:
#   - 不再覆盖 apt 源为已 EOL 的 buster archive (原 L8-9 的根因)
#   - 去掉 ssh/openssh-server (开发不需要, 且 buster 下依赖断裂)
#   - composer 改用官方 curl 安装器 (bullseye 源可正常装 git/curl)
#   - 暂不含 xdebug / node (按需后补; theme 构建可在宿主机或另配 node)
FROM ciandtchina/drupal-web:php8.3-fpm-apache

LABEL maintainer="local-dev (simplified)"

ENV MEMCACHED_VERSION=3.0.4

# git / rsync / unzip (mysql client 基础镜像已自带; mariadb dev lib 按需再加)
RUN apt-get update \
  && apt-get -y --no-install-recommends install git rsync unzip ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# intl 扩展 (编译)
RUN cd /usr/src/php/ext/intl \
  && phpize \
  && ./configure --enable-intl --with-php-config=/usr/local/bin/php-config \
  && make -j"$(nproc)" \
  && make install \
  && echo "extension=intl.so" > /usr/local/etc/php/conf.d/docker-php-ext-intl.ini

# composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# bcmath
RUN docker-php-ext-install bcmath

# 目录/权限 (与原镜像保持一致, 供 entrypoint 使用)
RUN mkdir -p /home/docker /var/www/keys \
  && ln -sf /var/www/keys /home/docker/.ssh \
  && touch /var/www/keys/known_hosts \
  && chown -R docker:docker /home/docker /var/www/keys
