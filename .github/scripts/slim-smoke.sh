#!/bin/sh
# Usage: slim-smoke.sh <cli|fpm|nginx|octane> <image> <major.minor> <minimum patch version>
set -eu
variant=$1 image=$2 version=$3 minimum=$4
name="dokar-slim-smoke-$variant-$$"
cleanup() { docker rm -f "$name" >/dev/null 2>&1 || true; }
trap cleanup EXIT
docker run --rm --entrypoint php "$image" -r '
  [$v, $min] = [$argv[1], $argv[2]];
  if (PHP_MAJOR_VERSION . "." . PHP_MINOR_VERSION !== $v || version_compare(PHP_VERSION, $min, "<")) { fwrite(STDERR, "bad php " . PHP_VERSION . "\n"); exit(41); }
  echo "php ", PHP_VERSION, "\n";' "$version" "$minimum"
docker run --rm --entrypoint composer "$image" --version
case "$variant" in
  fpm)
    docker run -d --name "$name" "$image" >/dev/null
    sleep 5
    docker exec "$name" php -r 'exit(@fsockopen("127.0.0.1", 9008) ? 0 : 1);' || { docker logs "$name"; exit 42; } ;;
  nginx)
    docker run -d --name "$name" "$image" >/dev/null
    printf '%s' '<?php echo "dokar-smoke-ok";' | docker exec -i "$name" sh -c 'cat > /var/www/public/__smoke.php'
    ok=false
    for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
      if docker exec "$name" curl -fsS http://127.0.0.1/__smoke.php 2>/dev/null | grep -qx dokar-smoke-ok; then ok=true; break; fi
      sleep 2
    done
    $ok || { docker logs "$name"; exit 43; } ;;
  octane)
    docker run --rm --entrypoint sh "$image" -c '
      printf "%s" "<?php \$s = new Swoole\\Http\\Server(\"127.0.0.1\", 9501); \$s->set([\"worker_num\" => 1]); \$s->on(\"request\", function (\$q, \$r) { \$r->end(\"swoole-ok\"); }); \$s->start();" > /tmp/s.php
      php /tmp/s.php >/dev/null 2>&1 & sleep 2
      curl -fsS http://127.0.0.1:9501/ | grep -qx swoole-ok && node -v' || exit 44 ;;
esac
echo "smoke ok: $variant"
