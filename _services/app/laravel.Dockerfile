FROM composer:latest
FROM php:fpm-alpine as base

ENV SERVICES_FOLDER _services
# CHECKME: name of this container
ENV CONTAINER_NAME app-yii

# CHECKME: name of process user
# files being chmodded to this perms
ENV USERNAME www-data
# ENV USERNAME 2000
ENV USERGROUP users


# set proccess user
RUN adduser -u  -G ${USERGROUP} -s /bin/sh -D ${USERNAME}

# prerequesite for php extentions

RUN apk update && apk upgrade

# tools
RUN apk add --no-cache lsof

# php83 \
RUN apk add --no-cache \
    php83-pdo_pgsql \
    oniguruma-dev \
    php-common  \
    libpq-dev \
    libcurl curl-dev  \
    libcrypto3 libssl3  \
    libzip-dev \
    libxml2-dev

WORKDIR $PKG_CONFIG_PATH

RUN docker-php-source extract

RUN docker-php-ext-configure    zip
RUN docker-php-ext-configure    phar
RUN docker-php-ext-configure    pcntl
RUN docker-php-ext-configure    pdo
RUN docker-php-ext-configure    pgsql
RUN docker-php-ext-configure    pdo_pgsql
RUN docker-php-ext-configure    session
RUN docker-php-ext-configure    dom
RUN docker-php-ext-configure    fileinfo
RUN docker-php-ext-configure    xml
RUN docker-php-ext-configure    xmlwriter

RUN docker-php-ext-install      zip
RUN docker-php-ext-install      phar
RUN docker-php-ext-install      pcntl
RUN docker-php-ext-install      pdo
RUN docker-php-ext-install      pgsql
RUN docker-php-ext-install      pdo_pgsql
RUN docker-php-ext-install      session
RUN docker-php-ext-install      dom
RUN docker-php-ext-install      fileinfo
RUN docker-php-ext-install      xml
RUN docker-php-ext-install      xmlwriter

RUN docker-php-ext-enable       zip
RUN docker-php-ext-enable       phar
RUN docker-php-ext-enable       pcntl
RUN docker-php-ext-enable       pdo
RUN docker-php-ext-enable       pgsql
RUN docker-php-ext-enable       pdo_pgsql
RUN docker-php-ext-enable       session
RUN docker-php-ext-enable       dom
RUN docker-php-ext-enable       fileinfo
RUN docker-php-ext-enable       xml
RUN docker-php-ext-enable       xmlwriter


RUN apk add \
    openrc \
    busybox \
    nginx \
    ca-certificates \
    --no-cache


COPY ./${SERVICES_FOLDER}/_nginx_common/ /etc/nginx/

EXPOSE 8000 80 8080 443

ADD --chown=${USERNAME}:users --chmod=775 ./${SERVICES_FOLDER}/${CONTAINER_NAME}/entrypoint.sh /usr/bin/
ENTRYPOINT /bin/ash /usr/bin/entrypoint.sh
