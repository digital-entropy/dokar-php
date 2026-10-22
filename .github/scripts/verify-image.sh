#!/usr/bin/env bash
set -euo pipefail
image=$1 version=$2 minimum=$3 variant=$4
scripts=$(cd "$(dirname "$0")" && pwd)
index=$(docker buildx imagetools inspect "$image" --raw)
repository=${image%@*}
for arch in amd64 arm64; do
 digest=$(printf '%s' "$index" | jq -er --arg arch "$arch" '.manifests[] | select(.platform.os == "linux" and .platform.architecture == $arch) | .digest')
 platform_image="$repository@$digest"
 docker pull --platform linux/$arch "$platform_image"
 docker run --rm -i --platform linux/$arch --network none --entrypoint sh "$platform_image" -s -- "$version" "$minimum" "$variant" < "$scripts/verify-runtime.sh"
 if [ "$variant" = nginx ]; then
  name="dokar-smoke-${GITHUB_RUN_ID:-local}-$arch"
  trap 'docker rm -f "$name" >/dev/null 2>&1 || true' EXIT
  docker run -d --platform linux/$arch --name "$name" "$platform_image"
  printf '%s' '<?php echo "dokar-smoke-ok";' | docker exec -i "$name" sh -c 'cat > /var/www/public/__dokar_smoke.php'
  ok=false
  for attempt in {1..30}; do
   if docker exec "$name" curl -fsS http://127.0.0.1/__dokar_smoke.php | grep -qx dokar-smoke-ok; then ok=true; break; fi
   sleep 2
  done
  "$ok" || { docker logs "$name"; exit 46; }
  docker rm -f "$name"
  trap - EXIT
 fi
done
