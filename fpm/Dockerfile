ARG BASE_IMAGE=ghcr.io/digital-entropy/dokar-php/cli:8.0
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.source https://github.com/digital-entropy/dokar-php

# Install FPM
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get -y --no-install-recommends install php8.0-fpm \
    && v=$(dpkg-query -W -f='${Version}' php8.0-fpm) && dpkg --compare-versions "$v" ge "1:8.0.30-25" \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# PHP-FPM packages need a nudge to make them docker-friendly
COPY overrides.conf /etc/php/8.0/fpm/pool.d/z-overrides.conf

# PHP-FPM has really dirty logs, certainly not good for dockerising
# The following startup script contains some magic to clean these up
COPY php-fpm-startup /usr/bin/php-fpm
CMD /usr/bin/php-fpm
