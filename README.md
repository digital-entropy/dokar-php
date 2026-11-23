# Dokar PHP

PHP **8.2** images on Ubuntu 22.04 (`jammy`), from branch `8.2`.

## Flavors

| Flavor | Description | Pull |
|---|---|---|
| CLI | PHP CLI with common extensions and Composer. Useful for Horizon, queue workers, schedulers and Tinker. | `docker pull ghcr.io/digital-entropy/dokar-php/cli:8.2` |
| PHP-FPM | PHP-FPM on top of the CLI image, listening on `fastcgi 0.0.0.0:9008`. | `docker pull ghcr.io/digital-entropy/dokar-php/fpm:8.2` |
| Nginx | Production-ready image with Nginx + PHP-FPM, serving `/var/www/public`. | `docker pull ghcr.io/digital-entropy/dokar-php/nginx:8.2` |
| Octane | Laravel Octane with the Swoole driver (built from source) and Node.js LTS. Set `DOCKER_WORKERS=` to choose workers. | `docker pull ghcr.io/digital-entropy/dokar-php/octane:8.2` |

> `-slim` (Alpine) images are not built for the 8.2 branch.

## Branches

| Branch | PHP | Base | Tags |
|---|---|---|---|
| `main` | 8.6 | Ubuntu 26.04 | `cli:8.6` `fpm:8.6` `nginx:8.6` (no octane / slim yet) |
| `8.5` | 8.5 | Ubuntu 24.04 | `*:8.5`, `*:8.5-slim` |
| `8.4` | 8.4 | Ubuntu 24.04 | `*:8.4`, `*:8.4-slim` |
| `8.3` | 8.3 | Ubuntu 24.04 | `*:8.3`, `*:8.3-slim` |
| `8.2` | 8.2 | Ubuntu 22.04 | `*:8.2` |

## How the images are built

- PHP comes from Ondřej Surý's repository at **packages.sury.org** (not the retired Launchpad PPA). The build checks the repository signing key fingerprint and fails if it does not match.
- Every build fails if the installed PHP is older than the latest security release for its branch, so a stale mirror never publishes a vulnerable image.
- PECL and php-pear are not included. To use Xdebug in a development image, install `php<ver>-xdebug` with `apt-get`.

Maintainer documentation (branch model, security release procedure, CI, known gaps): [docs/MAINTAINING.md](https://github.com/digital-entropy/dokar-php/blob/main/docs/MAINTAINING.md).
