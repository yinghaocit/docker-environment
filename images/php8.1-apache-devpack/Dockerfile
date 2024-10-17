FROM ciandtchina/drupal-web:php8.1-fpm-apache

LABEL maintainer="yinghao@ciandt.com"

ENV MEMCACHED_VERSION 3.0.4

ENV PATH="/var/www/html/vendor/bin:${PATH}"

RUN apt-get update \
  && apt-get -y install ssh rsync git unzip vim libfreetype6-dev libjpeg62-turbo-dev libpng-dev libwebp-dev

# Fix cannot connect mysql with caching_sha2_password plugin.
RUN apt-get -y install software-properties-common \
  && apt-get -y install libmariadbclient-dev

# Install npm
RUN apt-get -y install npm \
  && npm install -g n \
  && n 6

RUN curl -L -o /usr/local/bin/composer https://getcomposer.org/download/2.8.1/composer.phar \
  && chmod a+x /usr/local/bin/composer

# Install php ext
RUN cd /usr/src/php/ext/intl \
  && /usr/local/bin/phpize \
  && ./configure --enable-intl --with-php-config=/usr/local/bin/php-config \
  && make \
  && make install \
  && cd - \
  && echo "extension=intl.so" > /usr/local/etc/php/conf.d/docker-php-ext-intl.ini

RUN cd /usr/src/php/ext/gd \
  && /usr/local/bin/phpize \
  && ./configure --with-php-config=/usr/local/bin/php-config \
  && make \
  && make install \
  && cd -

RUN docker-php-ext-install bcmath

RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

RUN mkdir -p /home/docker \
  && mkdir -p /var/www/keys \
  && ln -s /var/www/keys /home/docker/.ssh \
  && ln -s /var/www/keys /root/.ssh \
  && chown docker:docker /home/docker

RUN touch /var/www/keys/known_hosts \
  && chown docker:docker /var/www/keys/known_hosts
