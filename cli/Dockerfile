FROM ubuntu:noble

LABEL org.opencontainers.image.source https://github.com/digital-entropy/dokar-php/tree/7.1

ENV DEBIAN_FRONTEND noninteractive

ENV TERM=linux

ENV TZ=UTC

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# noble ships an ubuntu user on UID/GID 1000, which the images below create themselves
RUN userdel -r ubuntu

RUN apt-get update \
    && apt-get install -y --no-install-recommends gnupg curl ca-certificates \
    && mkdir -p /etc/apt/keyrings \
    && curl -sS 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x14aa40ec0831756756d7f66c4f4ea0aae5267a6c' | gpg --dearmor | tee /etc/apt/keyrings/ppa_ondrej_php.gpg > /dev/null \
    && echo "deb [signed-by=/etc/apt/keyrings/ppa_ondrej_php.gpg] https://ppa.launchpadcontent.net/ondrej/php/ubuntu noble main" > /etc/apt/sources.list.d/ppa_ondrej_php.list \
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
        php7.1-cli \
        php7.1-curl \
        php7.1-mbstring \
        php7.1-opcache \
        php7.1-readline \
        php7.1-xml \
        php7.1-zip \
        php7.1-bcmath \
        php7.1-mysql \
        php7.1-pgsql \
        php7.1-redis \
        php7.1-gd \
        php7.1-sqlite3 \
        php7.1-soap \
        php7.1-xdebug \
    && v=$(dpkg-query -W -f='${Version}' php7.1-cli) && echo "php7.1-cli $v" \
    && dpkg --compare-versions "$v" ge "7.1.33-80" \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer global require --quiet --no-ansi laravel/envoy \
    && composer clear-cache --quiet \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* 

RUN ln -s /root/.composer/vendor/laravel/envoy/bin/envoy /usr/bin/envoy
