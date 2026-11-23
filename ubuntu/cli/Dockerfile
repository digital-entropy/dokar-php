FROM ubuntu:resolute

LABEL org.opencontainers.image.source=https://github.com/digital-entropy/dokar-php
LABEL org.opencontainers.image.branch=8.6

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
    && echo "Acquire::http::Pipeline-Depth 0;" > /etc/apt/apt.conf.d/99custom \
    && echo "Acquire::http::No-Cache true;" >> /etc/apt/apt.conf.d/99custom \
    && echo "Acquire::BrokenProxy    true;" >> /etc/apt/apt.conf.d/99custom \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL --retry 5 -o /tmp/debsuryorg-archive-keyring.deb https://packages.sury.org/debsuryorg-archive-keyring.deb \
    && dpkg-deb -x /tmp/debsuryorg-archive-keyring.deb /tmp/debsuryorg-keyring \
    && install -m 644 /tmp/debsuryorg-keyring/usr/share/keyrings/debsuryorg-archive-keyring.gpg /usr/share/keyrings/debsuryorg-archive-keyring.gpg \
    && test "$(gpg --show-keys --with-colons /usr/share/keyrings/debsuryorg-archive-keyring.gpg | awk -F: '$1=="pub"{getline; print $10}')" = "15058500A0235D97F5D10063B188E2B695BD4743" \
    && printf '%s\n' 'Types: deb' 'URIs: https://packages.sury.org/php/' "Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")" 'Components: main' 'Signed-By: /usr/share/keyrings/debsuryorg-archive-keyring.gpg' > /etc/apt/sources.list.d/debsuryorg-php.sources \
    && apt-get update \
    && apt-get install -y php8.6-cli php8.6-dev \
       php8.6-pgsql php8.6-sqlite3 php8.6-gd \
       php8.6-curl \
       php8.6-imap php8.6-mysql php8.6-mbstring \
       php8.6-xml php8.6-zip php8.6-bcmath php8.6-soap \
       php8.6-intl php8.6-readline \
       php8.6-ldap php8.6-redis php8.6-igbinary \
    && php8.6 -r 'foreach (["redis","igbinary"] as $ext) { if (!extension_loaded($ext)) { fwrite(STDERR, "Missing extension: $ext\n"); exit(1); } printf("%s=%s\n", $ext, phpversion($ext)); }' \
    && php8.6 -r 'printf("PHP runtime: %s\n", PHP_VERSION); exit(PHP_MAJOR_VERSION === 8 && PHP_MINOR_VERSION === 6 && version_compare(PHP_VERSION, "8.6.0", ">=") ? 0 : 42);' \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer global require --quiet --no-ansi laravel/envoy \
    && composer clear-cache --quiet \
    && apt autoremove -y build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* \
    && ln -s /root/.composer/vendor/laravel/envoy/bin/envoy /usr/bin/envoy
