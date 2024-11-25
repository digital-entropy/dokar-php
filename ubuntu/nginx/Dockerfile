FROM ghcr.io/digital-entropy/dokar-php/fpm:8.4

LABEL org.opencontainers.image.source=https://github.com/digital-entropy/dokar-php
LABEL org.opencontainers.image.branch=8.4

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
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

STOPSIGNAL SIGTERM

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
