FROM alpine:3

LABEL org.opencontainers.image.source=https://github.com/digital-entropy/dokar-php
LABEL org.opencontainers.image.branch=8.4

ENV TERM=linux

ENV TZ=UTC

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Composer is installed with this branch's PHP: Alpine's composer package pulls in another PHP version.
RUN apk add --no-cache \
      bash curl ca-certificates zip unzip git sqlite libcap gosu php84 php84-bcmath \
      php84-calendar php84-ctype php84-curl php84-dom php84-exif php84-ffi php84-fileinfo \
      php84-ftp php84-gd php84-gettext php84-iconv php84-intl php84-ldap php84-mbstring \
      php84-mysqli php84-openssl php84-pcntl php84-pdo php84-pdo_mysql php84-pdo_pgsql \
      php84-pdo_sqlite php84-pgsql php84-phar php84-posix php84-session php84-shmop \
      php84-simplexml php84-soap php84-sockets php84-sodium php84-sqlite3 php84-sysvmsg \
      php84-sysvsem php84-sysvshm php84-tokenizer php84-xml php84-xmlreader php84-xmlwriter \
      php84-xsl php84-zip php84-pecl-imap php84-opcache php84-pecl-igbinary php84-pecl-redis \
      php84-dev \
   && ln -sf /usr/bin/php84 /usr/bin/php \
   && php -r 'printf("PHP runtime: %s\n", PHP_VERSION); exit(PHP_MAJOR_VERSION === 8 && PHP_MINOR_VERSION === 4 && version_compare(PHP_VERSION, "8.4.28", ">=") ? 0 : 42);' \
   && php -r 'foreach (["ctype","curl","dom","fileinfo","filter","gd","iconv","igbinary","imap","intl","mbstring","openssl","pcntl","PDO","pdo_mysql","pdo_pgsql","pdo_sqlite","posix","redis","session","SimpleXML","sodium","tokenizer","xml","xmlreader","xmlwriter","zip","Zend OPcache"] as $e) { if (!extension_loaded($e)) { fwrite(STDERR, "Missing extension: $e\n"); exit(1); } }' \
   && curl -fsSL --retry 5 https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
   && composer global require --quiet --no-ansi laravel/envoy \
   && ln -s /root/.composer/vendor/laravel/envoy/bin/envoy /usr/bin/envoy \
   && composer clear-cache --quiet \
   && rm -rf /tmp/* /var/tmp/* /root/.npm
