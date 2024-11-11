FROM alpine:3.20

LABEL org.opencontainers.image.source=https://github.com/digital-entropy/dokar-php

ENV TERM=linux

ENV TZ=UTC

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apk update \
    && apk add --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing gosu \
    && apk add bash curl ca-certificates zip unzip git sqlite libcap libpng-dev \
        php83 php83-dev php83-gd php83-curl php83-soap  \
        php83-sqlite3 php83-pgsql php83-mysqli \
        php83-mbstring php83-xml php83-zip php83-bcmath \
        php83-intl php83-ldap \
        php83-pecl-igbinary php83-pecl-redis php83-pecl-swoole
    
RUN apk add composer \
    && composer global require --quiet --no-ansi laravel/envoy \
    && composer clear-cache --quiet \
    && ln -s /root/.composer/vendor/laravel/envoy/bin/envoy /usr/bin/envoy
    
RUN apk add nodejs npm \
    && npm install -g chokidar pnpm
    
RUN apk cache clean \
    && rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

COPY runner.sh /runner.sh

# Add a non-root user to prevent files being created with root permissions on host machine.
ONBUILD ARG USER_CONTAINER=dokar
ONBUILD ENV USER_CONTAINER=${USER_CONTAINER}
ONBUILD ARG PUID=1000
ONBUILD ENV PUID=${PUID}
ONBUILD ARG PGID=1000
ONBUILD ENV PGID=${PGID}

# Convert to alpine
ONBUILD RUN if [ "${PGID}" != "0" ] && [ "${PUID}" != "0" ]; then \
    (grep -q ":${PGID}:" /etc/group && old_group=$(getent group ${PGID} | cut -d: -f1) && delgroup ${old_group} \
        || addgroup -g ${PGID} ${USER_CONTAINER}) \
    && (grep -q ":${PUID}:" /etc/passwd && old_user=$(getent passwd ${PUID} | cut -d: -f1) && deluser --remove-home ${old_user} \
        || adduser -h /home/${USER_CONTAINER} -G ${USER_CONTAINER} -u ${PUID} ${USER_CONTAINER} -D) \
    fi

EXPOSE 80

WORKDIR /var/www

ARG DOCKER_ENV=production
ENV DOCKER_ENV=${DOCKER_ENV}
ENV DOCKER_WORKERS=auto

CMD ["/runner.sh"]
