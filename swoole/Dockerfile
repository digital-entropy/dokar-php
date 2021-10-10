FROM ghcr.io/digital-entropy/dokar-php/cli:8.0

RUN apt-get update \
    && apt-get -y --no-install-recommends install \
        build-essential \
        php-pear \
    && pecl channel-update https://pecl.php.net/channel.xml \
    && pecl install swoole \
    && pecl clear-cache \
    # cleaning...
    && apt autoremove -y build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* 

RUN COPY 20-swoole.conf /etc/php/8.0/cli/conf.d/20-swoole.conf

# Add a non-root user to prevent files being created with root permissions on host machine.
ONBUILD ARG USER_CONTAINER=dokar
ONBUILD ENV USER_CONTAINER ${USER_CONTAINER}
ONBUILD ARG PUID=1000
ONBUILD ENV PUID ${PUID}
ONBUILD ARG PGID=1000
ONBUILD ENV PGID ${PGID}

ONBUILD RUN groupadd -g ${PGID} ${USER_CONTAINER} && \
    useradd --gid ${PGID} --uid ${PUID} -m ${USER_CONTAINER}

ONBUILD RUN sed -i "/^\[www\]/a group=${USER_CONTAINER}" /etc/php/8.0/fpm/pool.d/z-overrides.conf && \
    sed -i "/^\[www\]/a user=${USER_CONTAINER}" /etc/php/8.0/fpm/pool.d/z-overrides.conf

EXPOSE 80
