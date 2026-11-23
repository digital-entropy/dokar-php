FROM alpine:3

LABEL org.opencontainers.image.source=https://github.com/digital-entropy/dokar-php
LABEL org.opencontainers.image.branch=8.6

ENV TERM=linux

ENV TZ=UTC

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Composer is installed with this branch's PHP: Alpine's composer package pulls in another PHP version.
RUN apk add --no-cache \
      bash curl ca-certificates zip unzip git sqlite libcap gosu php86 php86-bcmath \
      php86-calendar php86-ctype php86-curl php86-dom php86-exif php86-ffi php86-fileinfo \
      php86-ftp php86-gd php86-gettext php86-iconv php86-intl php86-ldap php86-mbstring \
      php86-mysqli php86-openssl php86-pcntl php86-pdo php86-pdo_mysql php86-pdo_pgsql \
      php86-pdo_sqlite php86-pgsql php86-phar php86-posix php86-session php86-shmop \
      php86-simplexml php86-soap php86-sockets php86-sodium php86-sqlite3 php86-sysvmsg \
      php86-sysvsem php86-sysvshm php86-tokenizer php86-xml php86-xmlreader php86-xmlwriter \
      php86-xsl php86-zip php86-pecl-imap php86-pecl-igbinary php86-pecl-redis php86-dev \
   && ln -sf /usr/bin/php86 /usr/bin/php \
   && php -r 'printf("PHP runtime: %s\n", PHP_VERSION); exit(PHP_MAJOR_VERSION === 8 && PHP_MINOR_VERSION === 6 && version_compare(PHP_VERSION, "8.6.0", ">=") ? 0 : 42);' \
   && php -r 'foreach (["ctype","curl","dom","fileinfo","filter","gd","iconv","igbinary","imap","intl","mbstring","openssl","pcntl","PDO","pdo_mysql","pdo_pgsql","pdo_sqlite","posix","redis","session","SimpleXML","sodium","tokenizer","xml","xmlreader","xmlwriter","zip","Zend OPcache"] as $e) { if (!extension_loaded($e)) { fwrite(STDERR, "Missing extension: $e\n"); exit(1); } }' \
   && curl -fsSL --retry 5 https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
   && composer global require --quiet --no-ansi laravel/envoy \
   && ln -s /root/.composer/vendor/laravel/envoy/bin/envoy /usr/bin/envoy \
   && composer clear-cache --quiet \
   && rm -rf /tmp/* /var/tmp/* /root/.npm
