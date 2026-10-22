ARG BASE_IMAGE=ghcr.io/digital-entropy/dokar-php/cli:8.1
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.source https://github.com/digital-entropy/dokar-php

RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential php-pear libbrotli-dev \
    && curl -fsSL --retry 5 --connect-timeout 15 --max-time 180 https://pecl.php.net/get/openswoole-22.1.2.tgz -o /tmp/extension.tgz \
    && printf '%s  %s\n' 'ec9d08e9484bf95a0080738342a84f09b9c5b8222f4a03c4736caacb7668cb46' /tmp/extension.tgz | sha256sum -c - \
    && pecl install /tmp/extension.tgz \
    && printf '%s\n' 'extension=openswoole.so' > /etc/php/8.1/cli/conf.d/20-openswoole.ini \
    && php8.1 -r 'if (phpversion("openswoole") !== "22.1.2") exit(42);' \
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

ONBUILD RUN if ! grep -q $PGID /etc/group; then groupadd -g ${PGID} ${USER_CONTAINER}; fi && \
    useradd --gid ${PGID} --uid ${PUID} -m ${USER_CONTAINER}

EXPOSE 80

WORKDIR /var/www

ARG DOCKER_ENV=production
ENV DOCKER_ENV ${DOCKER_ENV}

CMD "runuser" "-l" $USER_CONTAINER "-c" "/runner.sh $DOCKER_ENV"
