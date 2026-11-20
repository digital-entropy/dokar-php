ARG BASE_IMAGE=ghcr.io/digital-entropy/dokar-php/cli:8.3-slim
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.source=https://github.com/digital-entropy/dokar-php
LABEL org.opencontainers.image.branch=8.3

# PHP-FPM packages need a nudge to make them docker-friendly (Alpine reads /etc/php83/php-fpm.d)
COPY overrides.conf /etc/php83/php-fpm.d/z-overrides.conf
COPY php-fpm-startup /usr/bin/php-fpm

RUN apk add --no-cache php83-fpm \
    && chmod 755 /usr/bin/php-fpm \
    && /usr/sbin/php-fpm83 -t

CMD ["/usr/bin/php-fpm"]
