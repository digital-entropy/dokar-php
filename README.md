DOKAR PHP
--- 

PHP 8.3 of dokar-php

There is 4 variant in this images.

| Variant | Description | Usage |
| --- | --- | --- | 
| Only CLI | Provide only php-cli. This image can be useful to run such as `laravel-horizon, laravel-websocket, tinker`. | `docker pull ghcr.io/digital-entropy/dokar-php/cli:8.3` |
| Only PHP-FPM | Provide php-fpm from php-cli variant. This image listen on `fastcgi 0.0.0.0:9008`. | `docker pull ghcr.io/digital-entropy/dokar-php/fpm:8.3` |
| With Nginx | Production ready php image that use nginx as web server. This image will serve `/var/www/public` directory.   | `docker pull ghcr.io/digital-entropy/dokar-php/nginx:8.3` |
Octane | Crafted for running octane with `swoole` driver. use `DOCKER_WORKERS=` env to define specific worker you need.| `docker pull ghcr.io/digital-entropy/dokar-php/octane:8.3`
