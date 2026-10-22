#!/bin/sh
set -eu
version=$1 minimum=$2 variant=$3
for package in php"$version"-cli php"$version"-common; do
 installed=$(dpkg-query -W -f='${Version}' "$package")
 dpkg --compare-versions "$installed" ge "$minimum"
 printf '%s=%s\n' "$package" "$installed"
done
php -r 'if (PHP_MAJOR_VERSION . "." . PHP_MINOR_VERSION !== $argv[1]) exit(42); foreach (["redis","igbinary","curl","mbstring","PDO","pdo_mysql","pdo_pgsql","sqlite3","gd","soap","zip","dom"] as $e) { if (!extension_loaded($e)) { fwrite(STDERR,"Missing $e\n"); exit(43); } } $x=["probe"=>123]; if (igbinary_unserialize(igbinary_serialize($x)) !== $x || !defined("Redis::SERIALIZER_IGBINARY")) exit(44);' "$version"
composer --version
case "$variant" in
 fpm|nginx) installed=$(dpkg-query -W -f='${Version}' php"$version"-fpm); dpkg --compare-versions "$installed" ge "$minimum"; /usr/sbin/php-fpm"$version" -t;;
 octane) php -r 'if (!extension_loaded("swoole")) exit(45);';;
esac
test -z "$(find /var/lib/apt/lists -type f -name '*Packages*' -print -quit)"
