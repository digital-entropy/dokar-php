FROM ubuntu:noble

LABEL org.opencontainers.image.source=https://github.com/digital-entropy/dokar-php
LABEL org.opencontainers.image.branch=8.5

ENV DEBIAN_FRONTEND=noninteractive

ENV TERM=linux

ENV TZ=UTC

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Fail closed on missing repository indexes; retry transient downloads with backoff.
RUN printf '%s\n' 'Acquire::Retries "5";' 'Acquire::Retries::Delay "true";' 'Acquire::Retries::Delay::Maximum "30";' 'Acquire::http::Timeout "30";' 'Acquire::https::Timeout "30";' 'APT::Update::Error-Mode "any";' > /etc/apt/apt.conf.d/80-download-resilience

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
    && apt-get install -y php8.5-cli php8.5-dev \
       php8.5-pgsql php8.5-sqlite3 php8.5-gd \
       php8.5-curl \
       php8.5-imap php8.5-mysql php8.5-mbstring \
       php8.5-xml php8.5-zip php8.5-bcmath php8.5-soap \
       php8.5-intl php8.5-readline \
       php8.5-ldap php8.5-redis php8.5-igbinary php-pear \
    && php8.5 -r 'printf("PHP runtime: %s\n", PHP_VERSION); exit(PHP_MAJOR_VERSION === 8 && PHP_MINOR_VERSION === 5 && version_compare(PHP_VERSION, "8.5.12", ">=") ? 0 : 42);' \
    && curl -fsSL --retry 5 --connect-timeout 15 --max-time 180 https://pecl.php.net/get/swoole-6.2.3.tgz -o /tmp/swoole.tgz \
    && printf '%s  %s\n' '21dfa1c4a4a09f4d1cb4b154f7defdc91fbabafc8d44a77f8f618b9742c67304' /tmp/swoole.tgz | sha256sum -c - \
    && pecl install /tmp/swoole.tgz \
    && echo "extension=swoole.so" > /etc/php/8.5/cli/conf.d/20-swoole.ini \
    && php8.5 -r 'if (phpversion("swoole") !== "6.2.3") { fwrite(STDERR, "Unexpected swoole version\n"); exit(42); }' \
    && php8.5 -r 'foreach (["redis","igbinary","swoole"] as $ext) { if (!extension_loaded($ext)) { fwrite(STDERR, "Missing extension: $ext\n"); exit(1); } printf("%s=%s\n", $ext, phpversion($ext)); }' \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer global require --quiet --no-ansi laravel/envoy \
    && ln -s /root/.composer/vendor/laravel/envoy/bin/envoy /usr/bin/envoy \
    # octane use chokidar for --watch option so we need to install nodejs
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && NODE_MAJOR=22 \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt update && apt install nodejs -y \
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
