#!/bin/bash
set -Eeo pipefail
set -o errexit    # Used to exit upon error, avoiding cascading errors

IFS=$'\n\t'

cd /var/www

# read .env file
source <(grep -v '^#' .env | sed -E 's|^(.+)=(.*)$|: ${\1=\2}; export \1|g')

if [ -d vendor ]; then
    echo "vendor ok!"
else
    composer install
fi

if [ -d node_modules ]; then
    echo "node_modules ok!"
else
    npm install && npm install --dev chokidar
fi

if [ $APP_ENV == "production" ]; then
    php artisan octane:start --host=0.0.0.0 --port=80 -q
else 
    php artisan octane:start --host=0.0.0.0 --watch --port=80
fi
