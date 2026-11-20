FROM ubuntu:noble

LABEL org.opencontainers.image.source=https://github.com/digital-entropy/dokar-php
LABEL org.opencontainers.image.branch=8.4

ENV DEBIAN_FRONTEND=noninteractive

ENV TERM=linux

ENV TZ=UTC

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Fail closed on missing repository indexes; retry transient downloads with backoff.
RUN printf '%s\n' 'Acquire::Retries "5";' 'Acquire::Retries::Delay "true";' 'Acquire::Retries::Delay::Maximum "30";' 'Acquire::http::Timeout "30";' 'Acquire::https::Timeout "30";' 'APT::Update::Error-Mode "any";' > /etc/apt/apt.conf.d/80-download-resilience

# Swoole is built from the latest stable upstream tag; pin with --build-arg SWOOLE_VERSION=vX.Y.Z
ARG SWOOLE_VERSION=latest
RUN apt-get update \
    && apt-get install -y --no-install-recommends gnupg gosu curl ca-certificates zip unzip git sqlite3 libcap2-bin libpng-dev build-essential libbrotli-dev \
    && mkdir -p ~/.gnupg \
    && chmod 600 ~/.gnupg \
    && echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf \
    && echo "Acquire::http::Pipeline-Depth 0;" > /etc/apt/apt.conf.d/99custom \
    && echo "Acquire::http::No-Cache true;" >> /etc/apt/apt.conf.d/99custom \
    && echo "Acquire::BrokenProxy    true;" >> /etc/apt/apt.conf.d/99custom \
    && mkdir -p /etc/apt/keyrings \
    && curl -sS 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x14aa40ec0831756756d7f66c4f4ea0aae5267a6c' | gpg --dearmor | tee /etc/apt/keyrings/ppa_ondrej_php.gpg > /dev/null \
    && echo "deb [signed-by=/etc/apt/keyrings/ppa_ondrej_php.gpg] https://ppa.launchpadcontent.net/ondrej/php/ubuntu noble main" > /etc/apt/sources.list.d/ppa_ondrej_php.list \
    && apt-get update \
    && apt-get install -y php8.4-cli php8.4-dev \
       php8.4-pgsql php8.4-sqlite3 php8.4-gd \
       php8.4-curl \
       php8.4-imap php8.4-mysql php8.4-mbstring \
       php8.4-xml php8.4-zip php8.4-bcmath php8.4-soap \
       php8.4-intl php8.4-readline \
       php8.4-ldap php8.4-redis php8.4-igbinary \
    && php8.4 -r 'printf("PHP runtime: %s\n", PHP_VERSION); exit(PHP_MAJOR_VERSION === 8 && PHP_MINOR_VERSION === 4 && version_compare(PHP_VERSION, "8.4.28", ">=") ? 0 : 42);' \
    && SWOOLE_TAG="${SWOOLE_VERSION}" \
    && if [ "${SWOOLE_TAG}" = "latest" ]; then SWOOLE_TAG="$(git ls-remote --tags --refs https://github.com/swoole/swoole-src.git 'v*' | sed 's#.*refs/tags/##' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n 1)"; fi \
    && test -n "${SWOOLE_TAG}" \
    && echo "Building Swoole ${SWOOLE_TAG} from source" \
    && mkdir -p /tmp/swoole-src \
    && curl -fsSL --retry 5 --connect-timeout 15 --max-time 300 "https://github.com/swoole/swoole-src/archive/refs/tags/${SWOOLE_TAG}.tar.gz" | tar -xz -C /tmp/swoole-src --strip-components=1 \
    && (cd /tmp/swoole-src && phpize8.4 && ./configure --with-php-config=/usr/bin/php-config8.4 --enable-openssl --enable-brotli && make -j"$(nproc)" && make install) \
    && echo "extension=swoole.so" > /etc/php/8.4/cli/conf.d/20-swoole.ini \
    && SWOOLE_EXPECTED="${SWOOLE_TAG#v}" php8.4 -r 'if (phpversion("swoole") !== getenv("SWOOLE_EXPECTED")) { fwrite(STDERR, "Unexpected swoole version\n"); exit(42); }' \
    && php8.4 --ri swoole | grep -E '^(openssl|http2|brotli|zlib) =>' | wc -l | grep -qx 4 \
    && php8.4 -r 'foreach (["redis","igbinary","swoole"] as $ext) { if (!extension_loaded($ext)) { fwrite(STDERR, "Missing extension: $ext\n"); exit(1); } printf("%s=%s\n", $ext, phpversion($ext)); }' \
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
