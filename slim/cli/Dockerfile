FROM alpine:3

LABEL org.opencontainers.image.source=https://github.com/digital-entropy/dokar-php
LABEL org.opencontainers.image.branch=8.3

ENV TERM=linux

ENV TZ=UTC

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apk update \
   && apk add --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing gosu \
   && apk add bash curl ca-certificates zip unzip git sqlite libcap libpng-dev \
      php83 php83-dev php83-gd php83-curl php83-soap  \
      php83-sqlite3 php83-pgsql php83-mysqli \
      php83-mbstring php83-xml php83-zip php83-bcmath \
      php83-intl php83-ldap php83-pecl-igbinary php83-pecl-redis \
      composer \
   && apk cache clean \
   && rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

RUN composer global require --quiet --no-ansi laravel/envoy \
   && composer clear-cache --quiet \
   && ln -s /root/.composer/vendor/laravel/envoy/bin/envoy /usr/bin/envoy

