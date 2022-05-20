FROM ghcr.io/digital-entropy/dokar-php/cli:8.1

LABEL org.opencontainers.image.source https://github.com/digital-entropy/dokar-php

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C \
    && apt-get update \
    && apt-get -y --no-install-recommends install \
        build-essential \
        php-pear \
    # octane use chokidar for --watch option so we need to install nodejs
    && curl -sL https://deb.nodesource.com/setup_16.x | bash - \
    && apt install nodejs -y \
    && npm install -g chokidar \
    && pecl channel-update https://pecl.php.net/channel.xml \
    && pecl install openswoole \
    && pecl clear-cache \
    # cleaning...
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* 

COPY 20-openswoole.ini /etc/php/8.1/cli/conf.d/20-openswoole.ini
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
