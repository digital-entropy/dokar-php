FROM alpine:3

LABEL org.opencontainers.image.source=https://github.com/digital-entropy/dokar-php
LABEL org.opencontainers.image.branch=8.4

ENV TERM=linux

ENV TZ=UTC

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apk update \
   && apk add --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing gosu \
   && apk add bash curl ca-certificates zip unzip git sqlite libcap libpng-dev \
      php84 php84-dev php84-gd php84-curl php84-soap  \
      php84-sqlite3 php84-pgsql php84-mysqli \
      php84-mbstring php84-xml php84-zip php84-bcmath \
      php84-intl php84-ldap php84-pecl-igbinary php84-pecl-redis \
      composer \
   && apk cache clean \
   && rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

RUN composer global require --quiet --no-ansi laravel/envoy \
   && composer clear-cache --quiet \
   && ln -s /root/.composer/vendor/laravel/envoy/bin/envoy /usr/bin/envoy

