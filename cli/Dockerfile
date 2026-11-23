FROM ubuntu:jammy

LABEL org.opencontainers.image.source=https://github.com/digital-entropy/dokar-php

ENV DEBIAN_FRONTEND=noninteractive

ENV TERM=linux

ENV TZ=UTC

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# PHP comes from packages.sury.org (Ondrej Sury's repo; the Launchpad PPA is being retired).
# The keyring is extracted, not installed, and its single primary key must match the published fingerprint.
RUN printf '%s\n' 'Acquire::Retries "5";' 'Acquire::Retries::Delay "true";' 'Acquire::Retries::Delay::Maximum "30";' 'Acquire::http::Timeout "30";' 'Acquire::https::Timeout "30";' 'APT::Update::Error-Mode "any";' > /etc/apt/apt.conf.d/80-download-resilience \
    && apt-get update \
    && apt-get install -y gnupg gosu curl ca-certificates zip unzip git sqlite3 libcap2-bin libpng-dev \
    && mkdir -p ~/.gnupg \
    && chmod 600 ~/.gnupg \
    && echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf \
    && curl -fsSL --retry 5 -o /tmp/debsuryorg-archive-keyring.deb https://packages.sury.org/debsuryorg-archive-keyring.deb \
    && dpkg-deb -x /tmp/debsuryorg-archive-keyring.deb /tmp/debsuryorg-keyring \
    && install -m 644 /tmp/debsuryorg-keyring/usr/share/keyrings/debsuryorg-archive-keyring.gpg /usr/share/keyrings/debsuryorg-archive-keyring.gpg \
    && test "$(gpg --show-keys --with-colons /usr/share/keyrings/debsuryorg-archive-keyring.gpg | awk -F: '$1=="pub"{getline; print $10}')" = "15058500A0235D97F5D10063B188E2B695BD4743" \
    && printf '%s\n' 'Types: deb' 'URIs: https://packages.sury.org/php/' "Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")" 'Components: main' 'Signed-By: /usr/share/keyrings/debsuryorg-archive-keyring.gpg' > /etc/apt/sources.list.d/debsuryorg-php.sources \
    && apt-get update \
    && apt-get install -y php8.2-cli php8.2-dev \
       php8.2-pgsql php8.2-sqlite3 php8.2-gd \
       php8.2-curl \
       php8.2-imap php8.2-mysql php8.2-mbstring \
       php8.2-xml php8.2-zip php8.2-bcmath php8.2-soap \
       php8.2-intl php8.2-readline \
       php8.2-ldap php8.2-redis php8.2-igbinary \
    && php8.2 -r 'printf("PHP runtime: %s\n", PHP_VERSION); exit(PHP_MAJOR_VERSION === 8 && PHP_MINOR_VERSION === 2 && version_compare(PHP_VERSION, "8.2.36", ">=") ? 0 : 42);' \
    && php8.2 -r 'if (PHP_MAJOR_VERSION . "." . PHP_MINOR_VERSION !== "8.2") exit(42); foreach (["redis","igbinary","curl","mbstring","PDO","pdo_mysql","pdo_pgsql","sqlite3","gd","soap","zip","dom"] as $e) { if (!extension_loaded($e)) { fwrite(STDERR,"Missing $e\n"); exit(43); } }' \
    && curl -fsS --retry 5 https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer global require --quiet --no-ansi laravel/envoy \
    && composer clear-cache --quiet \
    && apt autoremove -y build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* \
    && ln -s /root/.composer/vendor/laravel/envoy/bin/envoy /usr/bin/envoy
