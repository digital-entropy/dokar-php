FROM ubuntu:focal

LABEL org.opencontainers.image.source https://github.com/digital-entropy/dokar-php

ENV DEBIAN_FRONTEND noninteractive

ENV TERM=linux

ENV TZ=UTC

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update \
    && apt-get install -y --no-install-recommends gnupg \
    && mkdir -p ~/.gnupg \
    && chmod 600 ~/.gnupg \
    && echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf \
    && apt-key adv --homedir ~/.gnupg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E5267A6C \
    && apt-key adv --homedir ~/.gnupg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C300EE8C \
    && echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu focal main" > /etc/apt/sources.list.d/ppa_ondrej_php.list \
    && apt-get update \
    && apt-get -y --no-install-recommends install \
        sqlite3 \ 
        libsqlite3-dev \
        dialog \
        ca-certificates \
        apt-utils \
        curl \
        unzip \
        openssh-client \
        git \
        php8.0-cli \
        php8.0-dev \
        php8.0-curl \
        php8.0-mbstring \
        php8.0-opcache \
        php8.0-readline \
        php8.0-xml \
        php8.0-zip \
        php8.0-bcmath \
        php8.0-mysql \
        php8.0-pgsql \
        php8.0-igbinary \
        php8.0-redis \
        php8.0-gd \
        php8.0-sqlite3 \
        php8.0-soap \
        php8.0-intl \
        php8.0-msgpack \
        php8.0-xdebug \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer global require --quiet --no-ansi laravel/envoy \
    && composer clear-cache --quiet \
    && apt autoremove -y build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* \
    && ln -s /root/.composer/vendor/laravel/envoy/bin/envoy /usr/bin/envoy
