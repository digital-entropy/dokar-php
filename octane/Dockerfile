ARG BASE_IMAGE=ghcr.io/digital-entropy/dokar-php/cli:8.2
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.source=https://github.com/digital-entropy/dokar-php

# Swoole is built from the latest stable upstream tag; pin with --build-arg SWOOLE_VERSION=vX.Y.Z
ARG SWOOLE_VERSION=latest
RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential libbrotli-dev \
    && SWOOLE_TAG="${SWOOLE_VERSION}" \
    && if [ "${SWOOLE_TAG}" = "latest" ]; then SWOOLE_TAG="$(git ls-remote --tags --refs https://github.com/swoole/swoole-src.git 'v*' | sed 's#.*refs/tags/##' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n 1)"; fi \
    && test -n "${SWOOLE_TAG}" \
    && echo "Building Swoole ${SWOOLE_TAG} from source" \
    && mkdir -p /tmp/swoole-src \
    && curl -fsSL --retry 5 --connect-timeout 15 --max-time 300 "https://github.com/swoole/swoole-src/archive/refs/tags/${SWOOLE_TAG}.tar.gz" | tar -xz -C /tmp/swoole-src --strip-components=1 \
    && (cd /tmp/swoole-src && phpize8.2 && ./configure --with-php-config=/usr/bin/php-config8.2 --enable-openssl --enable-brotli && make -j"$(nproc)" && make install) \
    && echo "extension=swoole.so" > /etc/php/8.2/cli/conf.d/20-swoole.ini \
    && SWOOLE_EXPECTED="${SWOOLE_TAG#v}" php8.2 -r 'if (phpversion("swoole") !== getenv("SWOOLE_EXPECTED")) { fwrite(STDERR, "Unexpected swoole version\n"); exit(42); }' \
    && php8.2 --ri swoole | grep -E '^(openssl|http2|brotli|zlib) =>' | wc -l | grep -qx 4 \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL --retry 5 https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && printf '%s\n' 'deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_26.x nodistro main' > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update && apt-get install -y nodejs \
    && npm install -g chokidar pnpm \
    && apt-get purge -y --auto-remove build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

COPY runner.sh /runner.sh

# Add a non-root user to prevent files being created with root permissions on host machine.
ONBUILD ARG USER_CONTAINER=dokar
ONBUILD ENV USER_CONTAINER=${USER_CONTAINER}
ONBUILD ARG PUID=1000
ONBUILD ENV PUID=${PUID}
ONBUILD ARG PGID=1000
ONBUILD ENV PGID=${PGID}

ONBUILD RUN if ! grep -q $PGID /etc/group; then groupadd -g ${PGID} ${USER_CONTAINER}; fi && \
    if ! grep -q $PUID /etc/passwd; then useradd --gid ${PGID} --uid ${PUID} -m ${USER_CONTAINER}; fi

EXPOSE 80

WORKDIR /var/www

ARG DOCKER_ENV=production
ENV DOCKER_ENV=${DOCKER_ENV}

CMD ["/bin/sh", "-c", "exec runuser -l \"$USER_CONTAINER\" -c \"/runner.sh $DOCKER_ENV\""]
