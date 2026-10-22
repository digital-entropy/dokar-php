ARG BASE_IMAGE=ghcr.io/digital-entropy/dokar-php/cli:8.0
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.source https://github.com/digital-entropy/dokar-php

RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential php-pear libbrotli-dev \
    && curl -fsSL --retry 5 --connect-timeout 15 --max-time 180 https://pecl.php.net/get/swoole-5.1.8.tgz -o /tmp/extension.tgz \
    && printf '%s  %s\n' 'c365ccd37b1804527064325a0d2641d4bc33fda23c5b4660dd840ac24f333aa8' /tmp/extension.tgz | sha256sum -c - \
    && pecl install /tmp/extension.tgz \
    && printf '%s\n' 'extension=swoole.so' > /etc/php/8.0/cli/conf.d/20-swoole.ini \
    && php8.0 -r 'if (phpversion("swoole") !== "5.1.8") exit(42);' \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL --retry 5 https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && printf '%s\n' 'deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main' > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update && apt-get install -y nodejs \
    && npm install -g chokidar pnpm \
    && apt-get purge -y --auto-remove build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

COPY runner.sh /runner.sh

# Add a non-root user to prevent files being created with root permissions on host machine.
ONBUILD ARG USER_CONTAINER=dokar
ONBUILD ENV USER_CONTAINER ${USER_CONTAINER}
ONBUILD ARG PUID=1000
ONBUILD ENV PUID ${PUID}
ONBUILD ARG PGID=1000
ONBUILD ENV PGID ${PGID}

ONBUILD RUN groupadd -g ${PGID} ${USER_CONTAINER} && \
    useradd --gid ${PGID} --uid ${PUID} -m ${USER_CONTAINER}

EXPOSE 80

WORKDIR /var/www

ARG DOCKER_ENV=production
ENV DOCKER_ENV ${DOCKER_ENV}

CMD "runuser" "-l" $USER_CONTAINER "-c" "/runner.sh $DOCKER_ENV"
