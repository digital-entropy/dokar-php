FROM ubuntu:noble

LABEL org.opencontainers.image.source=https://github.com/digital-entropy/dokar-php
LABEL org.opencontainers.image.branch=8.3

ENV DEBIAN_FRONTEND=noninteractive

ENV TERM=linux

ENV TZ=UTC

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Fail closed on missing repository indexes; retry transient downloads with backoff.
RUN printf '%s\n' 'Acquire::Retries "5";' 'Acquire::Retries::Delay "true";' 'Acquire::Retries::Delay::Maximum "30";' 'Acquire::http::Timeout "30";' 'Acquire::https::Timeout "30";' 'APT::Update::Error-Mode "any";' > /etc/apt/apt.conf.d/80-download-resilience

# PHP comes from packages.sury.org (Ondrej Sury's repo; the Launchpad PPA is being retired).
# The keyring is extracted, not installed, and its single primary key must match the published fingerprint.
RUN apt-get update \
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
    && apt-get install -y php8.3-cli php8.3-dev \
       php8.3-pgsql php8.3-sqlite3 php8.3-gd \
       php8.3-curl \
       php8.3-imap php8.3-mysql php8.3-mbstring \
       php8.3-xml php8.3-zip php8.3-bcmath php8.3-soap \
       php8.3-intl php8.3-readline \
       php8.3-ldap php8.3-redis php8.3-igbinary \
    && php8.3 -r 'foreach (["redis","igbinary"] as $ext) { if (!extension_loaded($ext)) { fwrite(STDERR, "Missing extension: $ext\n"); exit(1); } printf("%s=%s\n", $ext, phpversion($ext)); }' \
    && php8.3 -r 'printf("PHP runtime: %s\n", PHP_VERSION); exit(PHP_MAJOR_VERSION === 8 && PHP_MINOR_VERSION === 3 && version_compare(PHP_VERSION, "8.3.37", ">=") ? 0 : 42);' \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer global require --quiet --no-ansi laravel/envoy \
    && composer clear-cache --quiet \
    && apt autoremove -y build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* \
    && ln -s /root/.composer/vendor/laravel/envoy/bin/envoy /usr/bin/envoy
