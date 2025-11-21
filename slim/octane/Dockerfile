FROM alpine:3

LABEL org.opencontainers.image.source=https://github.com/digital-entropy/dokar-php
LABEL org.opencontainers.image.branch=8.5

ENV TERM=linux

ENV TZ=UTC

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apk update \
    && apk add --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing gosu \
    && apk add bash curl ca-certificates zip unzip git sqlite libcap libpng-dev \
        php85 php85-dev php85-gd php85-curl php85-soap  \
        php85-sqlite3 php85-pgsql php85-mysqli \
        php85-dom php85-tokenizer php85-fileinfo \
        php85-mbstring php85-xml php85-zip php85-bcmath \
        php85-intl php85-ldap \
        php85-pecl-igbinary php85-pecl-redis php85-pecl-swoole
    
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
