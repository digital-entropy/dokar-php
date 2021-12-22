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
        php8.1-cli \
        php8.1-dev \
        php8.1-curl \
        php8.1-mbstring \
        php8.1-opcache \
        php8.1-readline \
        php8.1-xml \
        php8.1-zip \
        php8.1-bcmath \
        php8.1-mysql \
        php8.1-pgsql \
        php8.1-igbinary \
        php8.1-redis \
        php8.1-gd \
        php8.1-sqlite3 \
        php8.1-soap \
        php8.1-intl \
        php8.1-msgpack \
        php8.1-xdebug \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer global require --quiet --no-ansi laravel/envoy \
    && composer clear-cache --quiet \
    && apt autoremove -y build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* \
    && ln -s /root/.composer/vendor/laravel/envoy/bin/envoy /usr/bin/envoy
