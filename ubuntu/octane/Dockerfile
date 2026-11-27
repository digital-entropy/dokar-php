# syntax=docker/dockerfile:1.10
FROM ubuntu:noble

LABEL org.opencontainers.image.source=https://github.com/digital-entropy/dokar-php
LABEL org.opencontainers.image.branch=8.3

ENV DEBIAN_FRONTEND=noninteractive

ENV TERM=linux

ENV TZ=UTC

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Fail closed on missing repository indexes; retry transient downloads with backoff.
RUN printf '%s\n' 'Acquire::Retries "5";' 'Acquire::Retries::Delay "true";' 'Acquire::Retries::Delay::Maximum "30";' 'Acquire::http::Timeout "30";' 'Acquire::https::Timeout "30";' 'APT::Update::Error-Mode "any";' > /etc/apt/apt.conf.d/80-download-resilience

# Swoole is installed with PIE (github.com/php/pie) from the swoole/swoole package: the newest stable
# release that supports this PHP. Pin with --build-arg SWOOLE_VERSION=6.3.0 (any Composer constraint).
# PIE downloads the source through the GitHub API; CI passes GITHUB_TOKEN as a build secret so the
# unauthenticated rate limit (60 requests/hour per IP) cannot break builds. It is never stored in the image.
ARG SWOOLE_VERSION=
ARG PIE_VERSION=1.6.1
ARG PIE_SHA256=e99400532e25cd3b65cb7b6688df93c9296a689f01bb0a4471869a3cbbac83ba
# PHP comes from packages.sury.org (Ondrej Sury's repo; the Launchpad PPA is being retired).
# The keyring is extracted, not installed, and its single primary key must match the published fingerprint.
RUN --mount=type=secret,id=github_token,env=GITHUB_TOKEN,required=false apt-get update \
    && apt-get install -y --no-install-recommends gnupg gosu curl ca-certificates zip unzip git sqlite3 libcap2-bin libpng-dev build-essential libbrotli-dev \
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
    && php8.3 -r 'printf("PHP runtime: %s\n", PHP_VERSION); exit(PHP_MAJOR_VERSION === 8 && PHP_MINOR_VERSION === 3 && version_compare(PHP_VERSION, "8.3.37", ">=") ? 0 : 42);' \
    && curl -fsSL --retry 5 -o /usr/local/bin/pie "https://github.com/php/pie/releases/download/${PIE_VERSION}/pie.phar" \
    && echo "${PIE_SHA256}  /usr/local/bin/pie" | sha256sum -c - \
    && chmod 755 /usr/local/bin/pie \
    && pie install --with-php-config=/usr/bin/php-config8.3 "swoole/swoole${SWOOLE_VERSION:+:${SWOOLE_VERSION}}" --enable-brotli \
    && php8.3 -r 'printf("swoole=%s\n", phpversion("swoole")); exit(version_compare(phpversion("swoole") ?: "0", "6.3.0", ">=") ? 0 : 42);' \
    && php8.3 --ri swoole | grep -E '^(openssl|http2|brotli|zlib) =>' | wc -l | grep -qx 4 \
    && rm -rf /root/.config/pie \
    && php8.3 -r 'foreach (["redis","igbinary","swoole"] as $ext) { if (!extension_loaded($ext)) { fwrite(STDERR, "Missing extension: $ext\n"); exit(1); } printf("%s=%s\n", $ext, phpversion($ext)); }' \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer global require --quiet --no-ansi laravel/envoy \
    && ln -s /root/.composer/vendor/laravel/envoy/bin/envoy /usr/bin/envoy \
    # octane use chokidar for --watch option so we need to install nodejs
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && NODE_MAJOR=26 \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt-get update && apt-get install -y nodejs \
    && npm install -g chokidar pnpm \
    # cleaning
    && composer clear-cache --quiet \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
        build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

COPY runner.sh /runner.sh

# Add a non-root user to prevent files being created with root permissions on host machine.
ONBUILD ARG USER_CONTAINER=dokar
ONBUILD ENV USER_CONTAINER=${USER_CONTAINER}
ONBUILD ARG PUID=1000
ONBUILD ENV PUID=${PUID}
ONBUILD ARG PGID=1000
ONBUILD ENV PGID=${PGID}

ONBUILD RUN if [ "${PGID}" != "0" ] && [ "${PUID}" != "0" ]; then \
    (grep -q ":${PGID}:" /etc/group && old_group=$(getent group ${PGID} | cut -d: -f1) && groupmod -n ${USER_CONTAINER} ${old_group} || groupadd -g ${PGID} ${USER_CONTAINER}) \
    && (grep -q ":${PUID}:" /etc/passwd && old_user=$(getent passwd ${PUID} | cut -d: -f1) && usermod -l ${USER_CONTAINER} -d /home/${USER_CONTAINER} -m ${old_user} || useradd --gid ${PGID} --uid ${PUID} -m ${USER_CONTAINER}) \
    fi

EXPOSE 80

WORKDIR /var/www

ARG DOCKER_ENV=production
ENV DOCKER_ENV=${DOCKER_ENV}
ENV DOCKER_WORKERS=auto

CMD ["/runner.sh"]
