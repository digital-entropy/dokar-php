FROM ghcr.io/digital-entropy/dokar-php/fpm:7.1

LABEL org.opencontainers.image.source https://github.com/digital-entropy/dokar-php/tree/7.1

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
ARG USER=dokar
ENV USER ${USER}
ARG PUID=1000
ENV PUID ${PUID}
ARG PGID=1000
ENV PGID ${PGID}

RUN groupadd -g ${PGID} ${USER} && \
    useradd --gid ${PGID} --uid ${PUID} ${USER}

RUN sed -i "/^\[www\]/a group=${USER}" /etc/php/7.1/fpm/pool.d/z-overrides.conf && \
    sed -i "/^\[www\]/a user=${USER}" /etc/php/7.1/fpm/pool.d/z-overrides.conf

EXPOSE 80

STOPSIGNAL SIGTERM

CMD /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
