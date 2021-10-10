FROM ghcr.io/digital-entropy/dokar-php/cli:8.0

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C \
    && apt-get update \
    && apt-get -y --no-install-recommends install \
        build-essential \
        php-pear \
    # octane use chokidar for --watch option so we need to install nodejs
    && curl -sL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt install nodejs -y \
    && pecl channel-update https://pecl.php.net/channel.xml \
    && pecl install swoole \
    && pecl clear-cache \
    # cleaning...
    && apt autoremove -y build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* 

COPY 20-swoole.ini /etc/php/8.0/cli/conf.d/20-swoole.ini
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

CMD "runuser" "-l" $USER_CONTAINER "-c" "/runner.sh"
