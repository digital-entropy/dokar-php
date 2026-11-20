FROM alpine:3

LABEL org.opencontainers.image.source=https://github.com/digital-entropy/dokar-php
LABEL org.opencontainers.image.branch=8.3

ENV TERM=linux

ENV TZ=UTC

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apk add --no-cache \
      bash curl ca-certificates zip unzip git sqlite libcap gosu php83 php83-bcmath \
      php83-calendar php83-ctype php83-curl php83-dom php83-exif php83-ffi php83-fileinfo \
      php83-ftp php83-gd php83-gettext php83-iconv php83-intl php83-ldap php83-mbstring \
      php83-mysqli php83-openssl php83-pcntl php83-pdo php83-pdo_mysql php83-pdo_pgsql \
      php83-pdo_sqlite php83-pgsql php83-phar php83-posix php83-session php83-shmop \
      php83-simplexml php83-soap php83-sockets php83-sodium php83-sqlite3 php83-sysvmsg \
      php83-sysvsem php83-sysvshm php83-tokenizer php83-xml php83-xmlreader php83-xmlwriter \
      php83-xsl php83-zip php83-imap php83-opcache php83-pecl-igbinary php83-pecl-redis \
      php83-pecl-swoole nodejs npm \
   && ln -sf /usr/bin/php83 /usr/bin/php \
   && php -r 'printf("PHP runtime: %s\n", PHP_VERSION); exit(PHP_MAJOR_VERSION === 8 && PHP_MINOR_VERSION === 3 && version_compare(PHP_VERSION, "8.3.37", ">=") ? 0 : 42);' \
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
