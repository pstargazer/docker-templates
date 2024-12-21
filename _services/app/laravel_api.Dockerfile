# FROM node:21-alpine AS node
FROM composer:latest AS composer
FROM php:fpm-alpine AS base

# name of domain to use in certs generating, nginx config
ARG _DOMAIN=example
# CHECKME: name of process user
# files being chmodded to this perms
ENV USERNAME www-data
ENV USERGROUP users

# path for app
ENV CMD_PATH=/var/www/html/
ENV CONF_INPUT=/tmp/nginx_conf/
ENV CONF_OUTPUT=/etc/nginx/


# set proccess user
RUN <<EOF
if !id "$1" >/dev/null 2>&1; then
    adduser -D -G ${USERGROUP} -s /bin/sh -H ${USERNAME}
fi
EOF

# crond jobs
COPY ./_services/app/cron.d/* /etc/periodic

# prerequesites for building php extentions
RUN <<EOF
apk update
apk upgrade
apk add --no-cache      \
    oniguruma-dev       \
    php-common          \
    libpq-dev           \
    libcurl curl-dev    \
    libcrypto3 libssl3  \
    libzip-dev          \
    libxml2-dev
EOF

# ============== PHP INSTALL ==============
WORKDIR $PKG_CONFIG_PATH
RUN docker-php-source extract

RUN <<EOF
    docker-php-ext-configure    zip
    docker-php-ext-install      zip
    docker-php-ext-enable       zip
EOF

RUN <<EOF
    docker-php-ext-configure    curl
    docker-php-ext-install      curl
    docker-php-ext-enable       curl
EOF

# RUN <<EOF
#     docker-php-ext-configure    phar
#     docker-php-ext-install      phar
#     docker-php-ext-enable       phar
# EOF
RUN <<EOF
    docker-php-ext-configure    pcntl
    docker-php-ext-install      pcntl
    docker-php-ext-enable       pcntl
EOF
RUN <<EOF
    docker-php-ext-configure    pdo
    docker-php-ext-install      pdo
    docker-php-ext-enable       pdo
EOF
RUN <<EOF
    docker-php-ext-configure    session
    docker-php-ext-install      session
    docker-php-ext-enable       session
EOF
RUN <<EOF
    docker-php-ext-configure    dom
    docker-php-ext-install      dom
    docker-php-ext-enable       dom
EOF
RUN <<EOF
    docker-php-ext-configure    fileinfo
    docker-php-ext-install      fileinfo
    docker-php-ext-enable       fileinfo
EOF
RUN <<EOF
    docker-php-ext-configure    xml
    docker-php-ext-install      xml
    docker-php-ext-enable       xml
EOF
RUN <<EOF
    docker-php-ext-configure    xmlwriter
    docker-php-ext-install      xmlwriter
    docker-php-ext-enable       xmlwriter
EOF

# optional, db extentions
RUN <<EOF
    docker-php-ext-configure    pgsql
    docker-php-ext-install      pgsql
    docker-php-ext-enable       pgsql

EOF

RUN <<EOF
    docker-php-ext-configure    pdo_pgsql
    docker-php-ext-install      pdo_pgsql
    docker-php-ext-enable       pdo_pgsql
EOF

# RUN <<EOF
#     docker-php-ext-configure    mysql
#     docker-php-ext-install      mysql
#     docker-php-ext-enable       mysql
# EOF

# RUN <<EOF
#     docker-php-ext-configure    pdo_mysql
#     docker-php-ext-install      pdo_mysql
#     docker-php-ext-enable       pdo_mysql
# EOF

# ============== PHP INSTALL END ==============


# get composer to avoid situation when exts cant be founded by composer
COPY --from=composer /usr/bin/composer /usr/bin/composer
# composer        \
RUN <<EOF
apk add --no-cache  \
    busybox         \
    nginx           \
    envsubst        \
    ca-certificates
EOF

# generating ssl cert
WORKDIR /etc/ssl
RUN <<EOF
openssl req -new -newkey rsa:4096 -days 365 -nodes -x509                \
    -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.${_DOMAIN}.com"   \
    -keyout ${_DOMAIN}.key  -out ${_DOMAIN}.cert
EOF


# ============== DEVELOPMENT ==============
FROM base AS development

# rewrite $_DOMAIN variable because nginx not supports env variables
WORKDIR ${CONF_INPUT}
COPY ./_services/app/nginx_conf_dev .
RUN <<EOF
envsubst '$_DOMAIN' < ./nginx.conf | tee ./nginx.conf.new
mv nginx.conf.new nginx.conf
rm -rf $CONF_OUTPUT/*
cp -rf ./* $CONF_OUTPUT
EOF

WORKDIR $CMD_PATH
COPY ./app_backend/ $CMD_PATH
VOLUME ["/var/www/html/vendor", "/var/www/html/storage"]

EXPOSE 8000 443
# clean up excess
RUN <<EOF
apk del     \
    envsubst
EOF

ADD --chown=${USERNAME}:users --chmod=775 ./_services/app/dev_entrypoint.sh ${CMD_PATH}/entrypoint-custom.sh
ENTRYPOINT ${CMD_PATH}/entrypoint-custom.sh
# ============== PRODUCTION ===============
FROM base AS production

# TODO: make expose_php = off

# rewrite $_DOMAIN variable because nginx not supports env variables
WORKDIR ${CONF_INPUT}
COPY ./_services/app/nginx_conf_prod .
RUN <<EOF
envsubst '$_DOMAIN' < ./nginx.conf | tee ./nginx.conf.new
mv nginx.conf.new nginx.conf
rm -rf $CONF_OUTPUT/*
cp -rf ./* $CONF_OUTPUT
EOF

WORKDIR $CMD_PATH
VOLUME ["/var/www/html/vendor", "/var/www/html/storage"]
COPY ./app_backend/ $CMD_PATH

# turn of expose_php due for security
RUN awk '{ if ($0 ~ /expose_php = Off/) { $0 = "expose_php = On" } print }' /usr/local/etc/php.ini > /usr/local/etc/php.ini

EXPOSE 80 443
# clean up excess
RUN <<EOF
apk del     \
    envsubst
EOF
# =========================================

# set process user
# do not set if crond needed
USER ${USERNAME}
# ADD --chown=${USERNAME}:users --chmod=775 ./_services/app/entrypoint.sh /usr/bin/

ENTRYPOINT ${CMD_PATH}/entrypoint-custom.sh
