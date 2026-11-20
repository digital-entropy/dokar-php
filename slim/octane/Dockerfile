FROM alpine:3

LABEL org.opencontainers.image.source=https://github.com/digital-entropy/dokar-php
LABEL org.opencontainers.image.branch=8.5

ENV TERM=linux

ENV TZ=UTC

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apk add --no-cache \
      bash curl ca-certificates zip unzip git sqlite libcap gosu php85 php85-bcmath \
      php85-calendar php85-ctype php85-curl php85-dom php85-exif php85-ffi php85-fileinfo \
      php85-ftp php85-gd php85-gettext php85-iconv php85-intl php85-ldap php85-mbstring \
      php85-mysqli php85-openssl php85-pcntl php85-pdo php85-pdo_mysql php85-pdo_pgsql \
      php85-pdo_sqlite php85-pgsql php85-phar php85-posix php85-session php85-shmop \
      php85-simplexml php85-soap php85-sockets php85-sodium php85-sqlite3 php85-sysvmsg \
      php85-sysvsem php85-sysvshm php85-tokenizer php85-xml php85-xmlreader php85-xmlwriter \
      php85-xsl php85-zip php85-pecl-imap php85-pecl-igbinary php85-pecl-redis \
      php85-pecl-swoole nodejs npm \
   && ln -sf /usr/bin/php85 /usr/bin/php \
   && php -r 'printf("PHP runtime: %s\n", PHP_VERSION); exit(PHP_MAJOR_VERSION === 8 && PHP_MINOR_VERSION === 5 && version_compare(PHP_VERSION, "8.5.13", ">=") ? 0 : 42);' \
   && php -r 'foreach (["ctype","curl","dom","fileinfo","filter","gd","iconv","igbinary","imap","intl","mbstring","openssl","pcntl","PDO","pdo_mysql","pdo_pgsql","pdo_sqlite","posix","redis","session","SimpleXML","sodium","tokenizer","xml","xmlreader","xmlwriter","zip","Zend OPcache","swoole"] as $e) { if (!extension_loaded($e)) { fwrite(STDERR, "Missing extension: $e\n"); exit(1); } }' \
   && curl -fsSL --retry 5 https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
   && composer global require --quiet --no-ansi laravel/envoy \
   && ln -s /root/.composer/vendor/laravel/envoy/bin/envoy /usr/bin/envoy \
   && php --ri swoole | grep -E '^(openssl|http2|brotli|zlib) =>' | wc -l | grep -qx 4 \
   && npm install -g chokidar pnpm \
   && npm cache clean --force \
   && composer clear-cache --quiet \
   && rm -rf /tmp/* /var/tmp/* /root/.npm

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
