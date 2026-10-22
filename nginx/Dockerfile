ARG BASE_IMAGE=ghcr.io/digital-entropy/dokar-php/fpm:8.0
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.source https://github.com/digital-entropy/dokar-php

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install nginx supervisor -y \
    && rm -f /etc/nginx/sites-enabled/* \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

RUN mkdir -p /var/www/public

COPY index.php /var/www/public

WORKDIR /var/www

COPY site.conf /etc/nginx/sites-enabled

COPY supervisor /etc/supervisor

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

STOPSIGNAL SIGTERM

CMD /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
