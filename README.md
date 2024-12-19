DOKAR PHP
--- 

PHP 8.4 of dokar-php

### There are 4 flavors in this image

| Flavor | Description | Usage |
| --- | --- | --- | 
| Only CLI | Provide only php-cli. This image can be useful to run such as `laravel-horizon, laravel-websocket, tinker`. | `docker pull ghcr.io/digital-entropy/dokar-php/cli:8.4` |
| Only PHP-FPM | Provide php-fpm from php-cli. This image listen on `fastcgi 0.0.0.0:9008`. | `docker pull ghcr.io/digital-entropy/dokar-php/fpm:8.4` |
| With Nginx | Production ready php image that use nginx as web server. This image will serve `/var/www/public` directory.   | `docker pull ghcr.io/digital-entropy/dokar-php/nginx:8.4` |
Octane | Crafted for running octane with `swoole` driver. use `DOCKER_WORKERS=` env to define specific worker you need.| `docker pull ghcr.io/digital-entropy/dokar-php/octane:8.4`

> Dokar PHP by default is using Ubuntu image, but we also provide Alpine image.
> You can add `-slim` in tag to use Alpine based image. e.g., `docker pull ghcr.io/digital-entropy/dokar-php/octane:8.4-slim` 
