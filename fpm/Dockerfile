FROM ghcr.io/digital-entropy/dokar-php/cli:8.3-slim

LABEL org.opencontainers.image.source=https://github.com/digital-entropy/dokar-php

# Install FPM
RUN apk update \
    && apk add php83-fpm \
    && apk cache clean \
    && rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

# PHP-FPM packages need a nudge to make them docker-friendly
COPY overrides.conf /etc/php/8.3/fpm/pool.d/z-overrides.conf

# PHP-FPM has really dirty logs, certainly not good for dockerising
# The following startup script contains some magic to clean these up
COPY php-fpm-startup /usr/bin/php-fpm
CMD /usr/bin/php-fpm
