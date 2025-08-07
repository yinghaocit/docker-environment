FROM ciandtchina/drupal-web:php8.3-fpm-apache

LABEL maintainer="yinghao@ciandt.com"

ENV MEMCACHED_VERSION 3.0.4

# Use Debian archive sources for Buster
RUN echo "deb http://archive.debian.org/debian buster main" > /etc/apt/sources.list \
  && echo "deb http://archive.debian.org/debian-security buster/updates main" >> /etc/apt/sources.list

RUN apt-get update \
  && apt-get -y install ssh rsync git unzip

# Fix cannot connect mysql with caching_sha2_password plugin.
RUN apt-get -y install software-properties-common \
  && apt-get -y install libmariadbclient-dev

# Install npm
RUN apt-get -y install npm \
  && npm install -g n \
  && n 6

# Install php ext
RUN cd /usr/src/php/ext/intl \
  && /usr/local/bin/phpize \
  && ./configure --enable-intl --with-php-config=/usr/local/bin/php-config \
  && make \
  && make install \
  && cd - \
  && echo "extension=intl.so" > /usr/local/etc/php/conf.d/docker-php-ext-intl.ini

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install php bcmath
RUN docker-php-ext-install bcmath

# Install php xdebug
RUN pecl install xdebug \
  && docker-php-ext-enable xdebug

RUN touch /tmp/xdebug.log \
  && chown docker:docker /tmp/xdebug.log

RUN mkdir -p /home/docker \
  && mkdir -p /var/www/keys \
  && ln -s /var/www/keys /home/docker/.ssh \
  && ln -s /var/www/keys /root/.ssh \
  && chown docker:docker /home/docker

RUN touch /var/www/keys/known_hosts \
  && chown docker:docker /var/www/keys/known_hosts

