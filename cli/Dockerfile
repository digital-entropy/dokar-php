FROM ubuntu:noble

LABEL org.opencontainers.image.source https://github.com/digital-entropy/dokar-php/tree/7.3

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
        php7.3-cli \
        php7.3-curl \
        php7.3-mbstring \
        php7.3-opcache \
        php7.3-readline \
        php7.3-xml \
        php7.3-zip \
        php7.3-bcmath \
        php7.3-mysql \
        php7.3-pgsql \
        php7.3-redis \
        php7.3-gd \
        php7.3-sqlite3 \
        php7.3-soap \
        php7.3-xdebug \
    && v=$(dpkg-query -W -f='${Version}' php7.3-cli) && echo "php7.3-cli $v" \
    && dpkg --compare-versions "$v" ge "7.3.33-35" \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer global require --quiet --no-ansi laravel/envoy \
    && composer clear-cache --quiet \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* 

RUN ln -s /root/.composer/vendor/laravel/envoy/bin/envoy /usr/bin/envoy
