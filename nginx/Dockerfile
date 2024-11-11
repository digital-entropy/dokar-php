FROM dokar-php/fpm:8.3-slim
# FROM ghcr.io/digital-entropy/dokar-php/fpm:8.3-slim

LABEL org.opencontainers.image.source=https://github.com/digital-entropy/dokar-php

RUN apk update \
    && apk add nginx supervisor \ 
    && apk cache clean \
    && rm -rf /var/cache/apk/* /tmp/* /var/tmp/* \
    && rm /etc/nginx/http.d/*

RUN mkdir -p /var/www/public

COPY index.php /var/www/public

WORKDIR /var/www

COPY site.conf /etc/nginx/http.d/site.conf

COPY supervisor /etc/supervisor

# Add a non-root user to prevent files being created with root permissions on host machine.
ONBUILD ARG USER_CONTAINER=dokar
ONBUILD ENV USER_CONTAINER=${USER_CONTAINER}
ONBUILD ARG PUID=1000
ONBUILD ENV PUID=${PUID}
ONBUILD ARG PGID=1000
ONBUILD ENV PGID=${PGID}

ONBUILD RUN if [ "${PGID}" != "0" ] && [ "${PUID}" != "0" ]; then \
    (grep -q ":${PGID}:" /etc/group && old_group=$(getent group ${PGID} | cut -d: -f1) && delgroup ${old_group} \
        || addgroup -g ${PGID} ${USER_CONTAINER}) \
    && (grep -q ":${PUID}:" /etc/passwd && old_user=$(getent passwd ${PUID} | cut -d: -f1) && deluser --remove-home ${old_user} \
        || adduser -h /home/${USER_CONTAINER} -G ${USER_CONTAINER} -u ${PUID} ${USER_CONTAINER} -D) \
    fi

EXPOSE 80

STOPSIGNAL SIGTERM

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
