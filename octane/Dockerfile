FROM ghcr.io/digital-entropy/dokar-php/cli:8.3

LABEL org.opencontainers.image.source https://github.com/digital-entropy/dokar-php

RUN apt-get update \
    && apt-get -y --no-install-recommends install \
        build-essential \
        php-pear \
    # octane use chokidar for --watch option so we need to install nodejs
    && curl -sL https://deb.nodesource.com/setup_18.x | bash - \
    && apt install nodejs -y \
    && npm install -g chokidar pnpm 

RUN pecl channel-update https://pecl.php.net/channel.xml
RUN pecl install swoole

COPY 20-extra.ini /etc/php/8.3/cli/conf.d/20-extra.ini
COPY runner.sh /runner.sh

# cleaning...
RUN pecl clear-cache \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* 

# Add a non-root user to prevent files being created with root permissions on host machine.
ONBUILD ARG USER_CONTAINER=dokar
ONBUILD ENV USER_CONTAINER ${USER_CONTAINER}
ONBUILD ARG PUID=1000
ONBUILD ENV PUID ${PUID}
ONBUILD ARG PGID=1000
ONBUILD ENV PGID ${PGID}

ONBUILD RUN if ! grep -q $PGID /etc/group; then groupadd -g ${PGID} ${USER_CONTAINER}; fi && \
    if ! grep -q $PUID /etc/passwd; then useradd --gid ${PGID} --uid ${PUID} -m ${USER_CONTAINER}; fi

EXPOSE 80

WORKDIR /var/www

ARG DOCKER_ENV=production
ENV DOCKER_ENV ${DOCKER_ENV}

CMD "runuser" "-l" $USER_CONTAINER "-c" "/runner.sh $DOCKER_ENV"
