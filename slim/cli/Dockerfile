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
      php85-intl php85-ldap php85-pecl-igbinary php85-pecl-redis \
      composer \
   && apk cache clean \
   && rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

RUN composer global require --quiet --no-ansi laravel/envoy \
   && composer clear-cache --quiet \
   && ln -s /root/.composer/vendor/laravel/envoy/bin/envoy /usr/bin/envoy

