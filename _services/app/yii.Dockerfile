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

# prerequesites for building php extentions
RUN <<EOF
apk update
apk upgrade
apk add --no-cache
    php83-pdo_pgsql
    oniguruma-dev
    php-common
    libpq-dev
    libcurl curl-dev
    libcrypto3 libssl3
    libzip-dev
    libxml2-dev
EOF

WORKDIR $PKG_CONFIG_PATH

RUN docker-php-source extract

RUN docker-php-ext-configure mbstring
RUN docker-php-ext-configure gd
RUN docker-php-ext-configure curl
RUN docker-php-ext-configure opcache
RUN docker-php-ext-configure pdo
RUN docker-php-ext-configure calendar
RUN docker-php-ext-configure ctype
RUN docker-php-ext-configure curl
RUN docker-php-ext-configure exif
RUN docker-php-ext-configure ffi
RUN docker-php-ext-configure fileinfo
RUN docker-php-ext-configure ftp
RUN docker-php-ext-configure gettext
RUN docker-php-ext-configure iconv
RUN docker-php-ext-configure phar
RUN docker-php-ext-configure posix
RUN docker-php-ext-configure readline
RUN docker-php-ext-configure shmop
RUN docker-php-ext-configure sockets
RUN docker-php-ext-configure sysvsem
RUN docker-php-ext-configure sysvshm
RUN docker-php-ext-configure tokenizer

RUN docker-php-ext-install mbstring
RUN docker-php-ext-install gd
RUN docker-php-ext-install curl
RUN docker-php-ext-install opcache
RUN docker-php-ext-install pdo
RUN docker-php-ext-install calendar
RUN docker-php-ext-install ctype
RUN docker-php-ext-install curl
RUN docker-php-ext-install exif
RUN docker-php-ext-install ffi
RUN docker-php-ext-install fileinfo
RUN docker-php-ext-install ftp
RUN docker-php-ext-install gettext
RUN docker-php-ext-install iconv
RUN docker-php-ext-install phar
RUN docker-php-ext-install posix
RUN docker-php-ext-install readline
RUN docker-php-ext-install shmop
RUN docker-php-ext-install sockets
RUN docker-php-ext-install sysvsem
RUN docker-php-ext-install sysvshm
RUN docker-php-ext-install tokenizer

RUN docker-php-ext-enable mbstring
RUN docker-php-ext-enable gd
RUN docker-php-ext-enable curl
RUN docker-php-ext-enable opcache
RUN docker-php-ext-enable pdo
RUN docker-php-ext-enable calendar
RUN docker-php-ext-enable ctype
RUN docker-php-ext-enable curl
RUN docker-php-ext-enable exif
RUN docker-php-ext-enable ffi
RUN docker-php-ext-enable fileinfo
RUN docker-php-ext-enable ftp
RUN docker-php-ext-enable gettext
RUN docker-php-ext-enable iconv
RUN docker-php-ext-enable phar
RUN docker-php-ext-enable posix
RUN docker-php-ext-enable readline
RUN docker-php-ext-enable shmop
RUN docker-php-ext-enable sockets
RUN docker-php-ext-enable sysvsem
RUN docker-php-ext-enable sysvshm
RUN docker-php-ext-enable tokenizer


RUN <<EOF
apk add --no-cache
    busybox
    nginx
    ca-certificates
EOF

# copy nginx conf
COPY ./${SERVICES_FOLDER}/_nginx_common/ /etc/nginx/

EXPOSE 8000 80 8080 443

ADD --chown=${USERNAME}:users --chmod=775 ./${SERVICES_FOLDER}/${CONTAINER_NAME}/entrypoint.sh /usr/bin/
ENTRYPOINT /bin/ash /usr/bin/entrypoint.sh
