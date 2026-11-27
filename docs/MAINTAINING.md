# Maintaining Dokar PHP

This page is the maintainer reference for the `digital-entropy/dokar-php` images: which branch builds which
tags, where PHP and Swoole come from, how a PHP security release is rolled out, and what CI does.
It lives on `main`; the version branches link here.

Last reviewed: 2026-11-27.

## Branches and tags

Each older PHP minor has its own long-lived branch. `main` carries the **newest PHP minor that every flavor
(including `octane`) supports**, currently 8.5. See [PHP 8.6 status](#php-86-status).

| Branch | PHP | Ubuntu base | Ubuntu tags | Slim (Alpine) tags | Status |
|---|---|---|---|---|---|
| `main` | **8.5** | 24.04 `noble` | `cli:8.5` `fpm:8.5` `nginx:8.5` `octane:8.5` | `*:8.5-slim` | active |
| `8.4` | 8.4 | 24.04 `noble` | `*:8.4` | `*:8.4-slim` | active |
| `8.3` | 8.3 | 24.04 `noble` | `*:8.3` | `*:8.3-slim` | active |
| `8.2` | 8.2 | 22.04 `jammy` | `*:8.2` (flat layout, candidate → verify → promote) | none | active, security-only upstream |
| `8.1`, `8.0`, `7.x` | EOL | old bases | `*:<ver>` | none | legacy, see [Legacy branches](#legacy-branches) |

All images are `ghcr.io/digital-entropy/dokar-php/<flavor>:<tag>` for `linux/amd64` and `linux/arm64`.

### Flavors

| Flavor | Built from | What it is |
|---|---|---|
| `cli` | `ubuntu:<codename>` | PHP CLI with the common extensions, Composer, Laravel Envoy, gosu |
| `fpm` | `cli:<ver>` | adds PHP-FPM, listening on `0.0.0.0:9008` |
| `nginx` | `fpm:<ver>` | adds Nginx + Supervisor, serves `/var/www/public` |
| `octane` | `ubuntu:<codename>` | PHP CLI + Swoole (installed with PIE) + Node.js LTS (26) with `chokidar` and `pnpm`, for Laravel Octane |

`fpm` and `nginx` are built `FROM` the published `cli`/`fpm` image, so CI builds them in order
(`build-fpm` needs `build-cli`, `build-nginx` needs `build-fpm`).

### History of the branch layout

- On 2026-11-23 `main` was briefly moved to PHP 8.6 on Ubuntu 26.04, with PHP 8.5 split off to an `8.5`
  branch. The 8.6 CI run was cancelled before it published anything, and `main` was reverted to 8.5 because
  Swoole does not support PHP 8.6. While `main` is 8.5, the `8.5` branch is redundant: **do not push to it**,
  because its CI would publish the same `*:8.5` tags as `main`.

## PHP 8.6 status

PHP 8.6.0 is final and packaged on packages.sury.org for Ubuntu 26.04 (`resolute`), amd64 and arm64. The
`cli`, `fpm` and `nginx` 8.6 images build and work (tested locally: same 64 extensions as 8.5, Nginx serves
PHP through FPM). **Swoole is the blocker:**

- No Swoole release supports PHP 8.6. Swoole 6.3.0 declares `php >=8.2 <8.6`, and the source stops with
  `#error "require PHP version 8.5 or earlier"`. With that check removed it still fails to compile
  (`XtOffsetOf` and `ZEND_PARSE_PARAMS_THROW` no longer exist in PHP 8.6).
- Upstream declined 8.6 for now: PRs #6025 and #6163 ("Add PHP 8.6 compatibility") were closed unmerged on
  2026-08-31 with "Support for 8.6 will not be considered in the short term". There is no milestone or branch.
- OpenSwoole 26.11 does run Octane on 8.6, but it is effectively a one-maintainer project with year-long gaps
  between releases, and its API differs (`Coroutine::sleep()` takes whole seconds only). Not used.

When a Swoole release supports 8.6, `pie install swoole/swoole` on an 8.6 image starts working. Then follow
[Starting a new PHP minor](#starting-a-new-php-minor).

## Where PHP comes from

### Ubuntu images: packages.sury.org

PHP is installed from **Ondřej Surý's repository at `packages.sury.org/php`**, not from the Launchpad PPA
`ppa:ondrej/php`.

Why: Ondřej is retiring the Launchpad PPA and moving Ubuntu packages to the server that already served Debian.
He announced it in February 2026, and it sped up after the May 2026 Launchpad outage. The PPA is being frozen
(its `Label` changes to `PPA for PHP (deprecated)`) and never carried Ubuntu 26.04. An image still built from
the PPA would silently stop getting PHP security releases.

How the Dockerfiles add it (same block on every branch):

1. Download `https://packages.sury.org/debsuryorg-archive-keyring.deb`.
2. Extract only the keyring file with `dpkg-deb -x`. The package is not installed, so none of its scripts run.
3. **Fail the build** unless the keyring holds exactly one primary key with fingerprint
   `15058500A0235D97F5D10063B188E2B695BD4743` (`DEB.SURY.ORG Automatic Signing Key`).
4. Write `/etc/apt/sources.list.d/debsuryorg-php.sources` (deb822). The suite is read from
   `/etc/os-release` (`VERSION_CODENAME`), so changing the `FROM` line is enough to move to another
   Ubuntu release.

Package versions from this repository look like `8.5.13-3+debsuryorg24.04.1+1`.

If Ondřej rotates the signing key, the fingerprint check fails the build on purpose. Verify the new
fingerprint on packages.sury.org before updating it in every branch.

### Slim images: Alpine

Slim images use Alpine's own `phpXY` packages (for example `php85`, `php85-fpm`). They follow Alpine's
release schedule, which is usually a few days behind php.net for security releases.

## Version guards (fail closed)

Every image build checks the PHP it just installed and **fails with exit code 42** if the version is older
than the minimum fixed release. This keeps a stale mirror or a delayed package from publishing a vulnerable image.

| Branch | Guard (minimum) | Where |
|---|---|---|
| `main` | 8.5.13 | `ubuntu/cli`, `ubuntu/octane`, `slim/*` Dockerfiles; `slim-smoke.sh` args in `ci-slim.yml` |
| `8.4` | 8.4.28 | same files |
| `8.3` | 8.3.37 | same files |
| `8.2` | 8.2.36 | `cli/Dockerfile`, `octane/Dockerfile` |

The octane build also fails unless Swoole is at least 6.3.0.

Raise the guard on every security release (see below). A slim CI run that fails with exit code 42 right after a
release is expected: it means Alpine has not shipped the fix yet, and nothing was published.

## Security release procedure

When php.net publishes security releases:

1. **Check package availability** on both architectures, for every suite we build:
   `https://packages.sury.org/php/dists/<suite>/main/binary-<arch>/Packages.xz` (suites `noble` and `jammy`;
   arches `amd64`, `arm64`). For slim, check Alpine's `community` APKINDEX for the stable release.
2. **Raise the version guards** on each branch to the new fixed versions (table above).
3. Build `cli` and `octane` locally on amd64 for at least one branch and check `PHP runtime:` in the log.
4. Commit per branch and push. Each push rebuilds that branch's images.
5. Verify the published tags: pull each flavor and run `php -v`; for `octane`, also `php --ri swoole`.
   arm64 can be checked from the CI log (`PHP runtime:` line of the arm64 build).
6. Applications only get the fix when they **rebuild and recreate** their containers. An Octane worker
   reload keeps the old PHP binary.

## Swoole (octane)

Swoole is installed with **[PIE](https://github.com/php/pie)**, the PHP Foundation's extension installer and
the successor to PECL, from the `swoole/swoole` package on Packagist. Swoole 6.3.0 is the first release that
ships PIE metadata.

- PIE picks the newest stable Swoole release whose declared PHP range includes the image's PHP. Pin a version
  with `--build-arg SWOOLE_VERSION=6.3.0` (any Composer constraint works).
- `pie.phar` is pinned with `ARG PIE_VERSION` and checked against `ARG PIE_SHA256`, the digest GitHub
  publishes for that release asset. Update both together.
- Build options: `--enable-brotli`; openssl, http2 and zlib are on by default. The build fails unless all four
  are present.
- PIE downloads Swoole's source through the GitHub API. CI passes the workflow's `GITHUB_TOKEN` as the BuildKit
  secret `github_token` (`RUN --mount=type=secret,id=github_token,env=GITHUB_TOKEN,required=false`), so the
  anonymous limit of 60 API requests per hour per IP cannot break builds. The token is not stored in any layer.
  Local builds work without it.
- `pie` stays in the image at `/usr/local/bin/pie`. The compiler is removed, so a downstream image that wants
  another extension must install `build-essential` and `php<ver>-dev` first.
- PECL and `php-pear` are not installed.
- Tested on 2026-11-27 (PHP 8.5.13, Swoole 6.3.0, amd64): coroutines, channels, hooked file/curl I/O, the raw
  HTTP server, and Laravel 13.44 + Octane 2.26 (start, 500 requests at 25 concurrency, reload) all passed.

## Xdebug and other dev extensions (downstream projects)

The images do not include Xdebug or `pecl`. A project's **local/dev** image should install Xdebug from the
same repository as PHP, so it always matches the runtime:

```dockerfile
FROM ghcr.io/digital-entropy/dokar-php/octane:8.5
RUN apt-get update \
    && apt-get install -y --no-install-recommends php8.5-xdebug \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
COPY ./conf.d/20-xdebug.ini /etc/php/8.5/mods-available/xdebug.ini
```

Keep the PHP version identical in the `FROM` tag, the package name and the ini path. Never build production
images from a Dockerfile that installs Xdebug.

## Slim (Alpine) images

- Built on Alpine stable with `phpXY` packages, published as `*:<ver>-slim`.
- CI builds amd64 first and runs `.github/scripts/slim-smoke.sh` (PHP version, Composer, FPM on port 9008,
  PHP through Nginx, Swoole HTTP), then builds and pushes both architectures.
- Slim octane uses Alpine's own `phpXY-pecl-swoole` package, not PIE.
- Alpine has no `php86` packages yet (checked 2026-11-23 on v3.24 and edge). Check that before moving `main`
  to 8.6; the slim workflow may need to stay manual-only until Alpine catches up.
- The legacy `8.3-slim` branch publishes the same `8.3-slim` tags as the `8.3` branch's slim workflow, with
  older, known-broken Dockerfiles. Do not push to it; delete it once nobody depends on it.

## CI

| Workflow | Branches | Triggers | What it does |
|---|---|---|---|
| `ci-ubuntu.yml` | `main`, `8.4`, `8.3` | push to that branch, schedule (every 14 days), manual | builds and pushes `cli`, `fpm`, `octane`, `nginx` for amd64 + arm64 |
| `ci-slim.yml` | `main`, `8.4`, `8.3` | push, schedule (monthly), manual | amd64 build + smoke test, then multi-arch push |
| `ci.yml` | `8.2` | push, manual | builds a `-candidate-<sha>` tag, verifies it on both arches, then promotes it |

Notes:

- Runners are `ubuntu-26.04`. This is the runner, not the image base; each image's base is its own `FROM`.
- **GitHub only runs `schedule` triggers on the default branch (`main`).** The version branches therefore only
  rebuild on push or manual dispatch; rebuild them by hand (`gh workflow run ci-ubuntu.yml --ref 8.4`) when a
  base image or PHP update should be picked up without a code change.
- Concurrency is per workflow and ref, with `cancel-in-progress: false`.
- arm64 builds run under QEMU emulation; the Swoole compile (via PIE) there takes about 20–25 minutes.
- Actions are kept current by Dependabot (`.github/dependabot.yml` on `main` lists every active branch as a
  target). Add new branches there.

## Starting a new PHP minor

Checklist (written while preparing 8.6; use it once Swoole supports 8.6):

1. Check that every PHP package the Dockerfiles install exists for the new version on **both** architectures
   in packages.sury.org, and that `pie install swoole/swoole` succeeds on it. Do not move `main` before that.
2. Create (or fast-forward) the branch for the current minor from `main`, e.g. `8.5`.
3. On that branch, change the `push` trigger in `ci-ubuntu.yml` and `ci-slim.yml` from `main` to the branch name.
4. On `main`, replace the version everywhere (`8.5` → `8.6`, `php85` → `php86`), reset the guards to the new
   release, and move `FROM` to the newest Ubuntu LTS that packages.sury.org supports.
5. Build all four Ubuntu flavors locally (build `fpm`/`nginx` on top of the local `cli`/`fpm` by tagging them
   with the ghcr names; do not push those local tags).
6. Add the new branch to `.github/dependabot.yml` on `main`, update `README.md` on both branches, and update the
   table at the top of this page.
7. Push the new branch first (it republishes the previous minor's tags unchanged), then `main`.

## Legacy branches

`8.1`, `8.0`, `7.4`, `7.3`, `7.2`, `7.1` (and the stale `7.3-1`) are end-of-life upstream. They were last
rebuilt in October 2026. They still install from the Launchpad PPA, so they need the same packages.sury.org
switch before their next rebuild, or they will stop receiving Ondřej's backported fixes.

## Known gaps

- arm64 images are only verified from CI build logs; there is no arm64 runtime test.
- `ubuntu/fpm/overrides.conf` sets `catch_workers_output = yes`. The 2026-11-19 PHP releases fix the related
  privilege bug (CVE-2026-129291), but turning it off is still worth considering.
- There is no automated test for the Ubuntu images beyond the build-time guards and extension checks.
