FROM ghcr.io/digital-entropy/dokar-php/fpm:8.1

LABEL org.opencontainers.image.source https://github.com/digital-entropy/dokar-php

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install software-properties-common -y \
    && add-apt-repository -y ppa:nginx/stable \
    && apt-get update \
    && apt-get install nginx supervisor -y \ 
    && rm /etc/nginx/sites-enabled/*

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

ONBUILD RUN if ! grep -q $PGID /etc/group; then groupadd -g ${PGID} ${USER_CONTAINER}; fi && \
    useradd --gid ${PGID} --uid ${PUID} -m ${USER_CONTAINER}

ONBUILD RUN sed -i "/^\[www\]/a group=${USER_CONTAINER}" /etc/php/8.1/fpm/pool.d/z-overrides.conf && \
    sed -i "/^\[www\]/a user=${USER_CONTAINER}" /etc/php/8.1/fpm/pool.d/z-overrides.conf

EXPOSE 80

STOPSIGNAL SIGTERM

CMD /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
