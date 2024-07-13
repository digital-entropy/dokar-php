#!/bin/bash
set -Eeo pipefail
set -o errexit    # Used to exit upon error, avoiding cascading errors

IFS=$'\n\t'

cd /var/www

if [ -d vendor ]; then
    echo "vendor ok!"
else
    composer install
fi

if [ -d node_modules ]; then
    echo "node_modules ok!"
else
    npm install
fi

echo "run on '$DOCKER_ENV' environment!"

if [ $DOCKER_ENV == "production" ]; then
    php artisan octane:start --host=0.0.0.0 --port=80
else
    php artisan octane:start --host=0.0.0.0 --watch --port=80
fi
