FROM ghcr.io/digital-entropy/dokar-php/cli:7.4

LABEL org.opencontainers.image.source https://github.com/digital-entropy/dokar-php/tree/7.4

# Install FPM
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get -y --no-install-recommends install php7.4-fpm \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# PHP-FPM packages need a nudge to make them docker-friendly
COPY overrides.conf /etc/php/7.4/fpm/pool.d/z-overrides.conf

# PHP-FPM has really dirty logs, certainly not good for dockerising
# The following startup script contains some magic to clean these up
COPY php-fpm-startup /usr/bin/php-fpm
CMD /usr/bin/php-fpm
