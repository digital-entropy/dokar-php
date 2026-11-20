FROM alpine:3

LABEL org.opencontainers.image.source=https://github.com/digital-entropy/dokar-php
LABEL org.opencontainers.image.branch=8.5

ENV TERM=linux

ENV TZ=UTC

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Composer is installed with this branch's PHP: Alpine's composer package pulls in another PHP version.
RUN apk add --no-cache \
      bash curl ca-certificates zip unzip git sqlite libcap gosu php85 php85-bcmath \
      php85-calendar php85-ctype php85-curl php85-dom php85-exif php85-ffi php85-fileinfo \
      php85-ftp php85-gd php85-gettext php85-iconv php85-intl php85-ldap php85-mbstring \
      php85-mysqli php85-openssl php85-pcntl php85-pdo php85-pdo_mysql php85-pdo_pgsql \
      php85-pdo_sqlite php85-pgsql php85-phar php85-posix php85-session php85-shmop \
      php85-simplexml php85-soap php85-sockets php85-sodium php85-sqlite3 php85-sysvmsg \
      php85-sysvsem php85-sysvshm php85-tokenizer php85-xml php85-xmlreader php85-xmlwriter \
      php85-xsl php85-zip php85-pecl-imap php85-pecl-igbinary php85-pecl-redis php85-dev \
   && ln -sf /usr/bin/php85 /usr/bin/php \
   && php -r 'printf("PHP runtime: %s\n", PHP_VERSION); exit(PHP_MAJOR_VERSION === 8 && PHP_MINOR_VERSION === 5 && version_compare(PHP_VERSION, "8.5.13", ">=") ? 0 : 42);' \
   && php -r 'foreach (["ctype","curl","dom","fileinfo","filter","gd","iconv","igbinary","imap","intl","mbstring","openssl","pcntl","PDO","pdo_mysql","pdo_pgsql","pdo_sqlite","posix","redis","session","SimpleXML","sodium","tokenizer","xml","xmlreader","xmlwriter","zip","Zend OPcache"] as $e) { if (!extension_loaded($e)) { fwrite(STDERR, "Missing extension: $e\n"); exit(1); } }' \
   && curl -fsSL --retry 5 https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
   && composer global require --quiet --no-ansi laravel/envoy \
   && ln -s /root/.composer/vendor/laravel/envoy/bin/envoy /usr/bin/envoy \
   && composer clear-cache --quiet \
   && rm -rf /tmp/* /var/tmp/* /root/.npm
