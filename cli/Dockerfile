FROM ubuntu:focal

LABEL org.opencontainers.image.source https://github.com/digital-entropy/dokar-php/tree/7.4

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
        apt-utils \
        ca-certificates \
        curl \
        unzip \
        openssh-server \
        git \
        php7.4-cli \
        php7.4-curl \
        php7.4-mbstring \
        php7.4-opcache \
        php7.4-readline \
        php7.4-xml \
        php7.4-zip \
        php7.4-bcmath \
        php7.4-mysql \
        php7.4-pgsql \
        php7.4-redis \
        php7.4-gd \
        php7.4-sqlite3 \
        php7.4-soap \
        php7.4-xdebug \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer global require --quiet --no-ansi laravel/envoy \
    && composer clear-cache --quiet \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* 

RUN ln -s /root/.composer/vendor/laravel/envoy/bin/envoy /usr/bin/envoy
