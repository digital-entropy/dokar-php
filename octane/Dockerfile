# syntax=docker/dockerfile:1.10
ARG BASE_IMAGE=ghcr.io/digital-entropy/dokar-php/cli:8.2
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.source=https://github.com/digital-entropy/dokar-php

# Swoole is installed with PIE (github.com/php/pie) from the swoole/swoole package: the newest stable
# release that supports this PHP. Pin with --build-arg SWOOLE_VERSION=6.3.0 (any Composer constraint).
# PIE downloads the source through the GitHub API; CI passes GITHUB_TOKEN as a build secret so the
# unauthenticated rate limit (60 requests/hour per IP) cannot break builds. It is never stored in the image.
ARG SWOOLE_VERSION=
ARG PIE_VERSION=1.6.1
ARG PIE_SHA256=e99400532e25cd3b65cb7b6688df93c9296a689f01bb0a4471869a3cbbac83ba
RUN --mount=type=secret,id=github_token,env=GITHUB_TOKEN,required=false apt-get update \
    && apt-get install -y --no-install-recommends build-essential libbrotli-dev \
    && curl -fsSL --retry 5 -o /usr/local/bin/pie "https://github.com/php/pie/releases/download/${PIE_VERSION}/pie.phar" \
    && echo "${PIE_SHA256}  /usr/local/bin/pie" | sha256sum -c - \
    && chmod 755 /usr/local/bin/pie \
    && pie install --with-php-config=/usr/bin/php-config8.2 "swoole/swoole${SWOOLE_VERSION:+:${SWOOLE_VERSION}}" --enable-brotli \
    && php8.2 -r 'printf("swoole=%s\n", phpversion("swoole")); exit(version_compare(phpversion("swoole") ?: "0", "6.3.0", ">=") ? 0 : 42);' \
    && php8.2 --ri swoole | grep -E '^(openssl|http2|brotli|zlib) =>' | wc -l | grep -qx 4 \
    && rm -rf /root/.config/pie \
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
