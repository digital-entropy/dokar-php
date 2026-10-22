FROM ubuntu:noble

LABEL org.opencontainers.image.source https://github.com/digital-entropy/dokar-php

ENV DEBIAN_FRONTEND noninteractive

ENV TERM=linux

ENV TZ=UTC

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# noble ships an ubuntu user on UID/GID 1000, which the images below create themselves
RUN userdel -r ubuntu

RUN printf '%s\n' 'Acquire::Retries "5";' 'Acquire::Retries::Delay "true";' 'Acquire::Retries::Delay::Maximum "30";' 'Acquire::http::Timeout "30";' 'Acquire::https::Timeout "30";' 'APT::Update::Error-Mode "any";' > /etc/apt/apt.conf.d/80-download-resilience \
    && apt-get update \
    && apt-get install -y --no-install-recommends gnupg curl ca-certificates \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsS --retry 5 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x14aa40ec0831756756d7f66c4f4ea0aae5267a6c' | gpg --dearmor | tee /etc/apt/keyrings/ppa_ondrej_php.gpg > /dev/null \
    && echo "deb [signed-by=/etc/apt/keyrings/ppa_ondrej_php.gpg] https://ppa.launchpadcontent.net/ondrej/php/ubuntu noble main" > /etc/apt/sources.list.d/ppa_ondrej_php.list \
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
    && v=$(dpkg-query -W -f='${Version}' php8.1-cli) && echo "php8.1-cli $v" \
    && dpkg --compare-versions "$v" ge "8.1.34-9" \
    && php8.1 -r 'if (PHP_MAJOR_VERSION . "." . PHP_MINOR_VERSION !== "8.1") exit(42); foreach (["redis","igbinary","curl","mbstring","PDO","pdo_mysql","pdo_pgsql","sqlite3","gd","soap","zip","dom"] as $e) { if (!extension_loaded($e)) { fwrite(STDERR,"Missing $e\n"); exit(43); } }' \
    && curl -fsS --retry 5 https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer global require --quiet --no-ansi laravel/envoy \
    && composer clear-cache --quiet \
    && apt autoremove -y build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* \
    && ln -s /root/.composer/vendor/laravel/envoy/bin/envoy /usr/bin/envoy
