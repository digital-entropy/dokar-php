FROM alpine:3

LABEL org.opencontainers.image.source=https://github.com/digital-entropy/dokar-php
LABEL org.opencontainers.image.branch=8.3

ENV TERM=linux

ENV TZ=UTC

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Composer is installed with this branch's PHP: Alpine's composer package pulls in another PHP version.
RUN apk add --no-cache \
      bash curl ca-certificates zip unzip git sqlite libcap gosu php83 php83-bcmath \
      php83-calendar php83-ctype php83-curl php83-dom php83-exif php83-ffi php83-fileinfo \
      php83-ftp php83-gd php83-gettext php83-iconv php83-intl php83-ldap php83-mbstring \
      php83-mysqli php83-openssl php83-pcntl php83-pdo php83-pdo_mysql php83-pdo_pgsql \
      php83-pdo_sqlite php83-pgsql php83-phar php83-posix php83-session php83-shmop \
      php83-simplexml php83-soap php83-sockets php83-sodium php83-sqlite3 php83-sysvmsg \
      php83-sysvsem php83-sysvshm php83-tokenizer php83-xml php83-xmlreader php83-xmlwriter \
      php83-xsl php83-zip php83-imap php83-opcache php83-pecl-igbinary php83-pecl-redis \
      php83-dev \
   && ln -sf /usr/bin/php83 /usr/bin/php \
   && php -r 'printf("PHP runtime: %s\n", PHP_VERSION); exit(PHP_MAJOR_VERSION === 8 && PHP_MINOR_VERSION === 3 && version_compare(PHP_VERSION, "8.3.37", ">=") ? 0 : 42);' \
   && php -r 'foreach (["ctype","curl","dom","fileinfo","filter","gd","iconv","igbinary","imap","intl","mbstring","openssl","pcntl","PDO","pdo_mysql","pdo_pgsql","pdo_sqlite","posix","redis","session","SimpleXML","sodium","tokenizer","xml","xmlreader","xmlwriter","zip","Zend OPcache"] as $e) { if (!extension_loaded($e)) { fwrite(STDERR, "Missing extension: $e\n"); exit(1); } }' \
   && curl -fsSL --retry 5 https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
   && composer global require --quiet --no-ansi laravel/envoy \
   && ln -s /root/.composer/vendor/laravel/envoy/bin/envoy /usr/bin/envoy \
   && composer clear-cache --quiet \
   && rm -rf /tmp/* /var/tmp/* /root/.npm
