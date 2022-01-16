FROM ubuntu:20.04

RUN set -e; \
    export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    apt-get dist-upgrade -y; \
    apt-get install -y --no-install-recommends \
        tini \
        crudini \
        php-common \
        php-fpm \
        php-mysql \
        php-xml \
        php-gd \
        php-mbstring \
        php-curl \
        php-zip \
        php-cli \
        php-json \
        php-opcache \
        php-readline \
        composer \
        less \
        curl; \
    curl https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp; \
    chmod -v 0755 /usr/local/bin/wp; \
    wp --info; \
    apt-get purge -y curl; \
    apt-get autoremove -y; \
    apt-get clean; \
    rm -rvf /var/lib/apt/lists/*

ENV DOCKER_RUN_AS_UID=0
ENV DOCKER_RUN_AS_GID=0

# RUN set -e; \
#     mkdir -v /run/php; \
#     chmod -v 0777 /run/php
RUN set -e; \
    chmod -v 0777 /run/php

VOLUME [ "/var/www/html" ]

EXPOSE 9000

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN set -e; \
    chmod -v 0755 /docker-entrypoint.sh; \
    chown -v root:root /docker-entrypoint.sh

COPY php-fpm.conf /etc/php/7.4/fpm/php-fpm.conf
RUN set -e; \
    chmod -v 0644 /etc/php/7.4/fpm/php-fpm.conf; \
    chown -v root:root /etc/php/7.4/fpm/php-fpm.conf

COPY www.conf /etc/php/7.4/fpm/pool.d/www.conf
RUN set -e; \
    chmod -v 0644 /etc/php/7.4/fpm/pool.d/www.conf; \
    chown -v root:root /etc/php/7.4/fpm/pool.d/www.conf

COPY php.ini /etc/php/7.4/fpm/php.ini
RUN set -e; \
    chmod -v 0644 /etc/php/7.4/fpm/php.ini; \
    chown -v root:root /etc/php/7.4/fpm/php.ini

ENTRYPOINT ["tini", "--"]
CMD ["/docker-entrypoint.sh"]
