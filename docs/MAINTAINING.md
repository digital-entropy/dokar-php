# Maintaining Dokar PHP

This page is the maintainer reference for the `digital-entropy/dokar-php` images: which branch builds which
tags, where PHP comes from, how a PHP security release is rolled out, and what CI does.
It lives on `main`; the version branches link here.

Last reviewed: 2026-11-23.

## Branches and tags

Each PHP minor version has its own long-lived branch. `main` always carries the **newest** PHP minor.

| Branch | PHP | Ubuntu base | Ubuntu tags | Slim (Alpine) tags | Status |
|---|---|---|---|---|---|
| `main` | **8.6** | 26.04 `resolute` | `cli:8.6` `fpm:8.6` `nginx:8.6` (**no `octane:8.6` yet**, see [Swoole](#swoole-octane)) | not published yet (see [Slim](#slim-alpine-images)) | active |
| `8.5` | 8.5 | 24.04 `noble` | `cli:8.5` `fpm:8.5` `nginx:8.5` `octane:8.5` | `*:8.5-slim` | active |
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
| `octane` | `ubuntu:<codename>` | PHP CLI + Swoole (built from source) + Node.js LTS (26) with `chokidar` and `pnpm`, for Laravel Octane |

`fpm` and `nginx` are built `FROM` the published `cli`/`fpm` image, so CI builds them in order
(`build-fpm` needs `build-cli`, `build-nginx` needs `build-fpm`).

### History of the branch layout

- Until 2026-11-23, `main` was PHP 8.5. On that date `main` was branched to `8.5` (the branch starts at
  commit `30f370a`, which is identical to what `main` was) and `main` moved to PHP 8.6 on Ubuntu 26.04.
- When PHP 8.7 ships, repeat the procedure in [Starting a new PHP minor](#starting-a-new-php-minor).

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
| `main` | 8.6.0 | `ubuntu/cli`, `ubuntu/octane`, `slim/*` Dockerfiles; `slim-smoke.sh` args in `ci-slim.yml` |
| `8.5` | 8.5.13 | same files |
| `8.4` | 8.4.28 | same files |
| `8.3` | 8.3.37 | same files |
| `8.2` | 8.2.36 | `cli/Dockerfile`, `octane/Dockerfile` |

Raise the guard on every security release (see below). A slim CI run that fails with exit code 42 right after a
release is expected: it means Alpine has not shipped the fix yet, and nothing was published.

## Security release procedure

When php.net publishes security releases:

1. **Check package availability** on both architectures, for every suite we build:
   `https://packages.sury.org/php/dists/<suite>/main/binary-<arch>/Packages.xz` (suites `resolute`, `noble`,
   `jammy`; arches `amd64`, `arm64`). For slim, check Alpine's `community` APKINDEX for the stable release.
2. **Raise the version guards** on each branch to the new fixed versions (table above).
3. Build `cli` and `octane` locally on amd64 for at least one branch and check `PHP runtime:` in the log.
4. Commit per branch and push. Each push rebuilds that branch's images.
5. Verify the published tags: pull each flavor and run `php -v`; for `octane`, also `php --ri swoole`.
   arm64 can be checked from the CI log (`PHP runtime:` line of the arm64 build).
6. Applications only get the fix when they **rebuild and recreate** their containers. An Octane worker
   reload keeps the old PHP binary.

## Swoole (octane)

- Swoole is **built from source** from the latest stable `swoole-src` tag (`vX.Y.Z`, release candidates are
  skipped). Pin a version with `--build-arg SWOOLE_VERSION=vX.Y.Z`.
- The build fails unless the loaded Swoole version equals the tag and `openssl`, `http2`, `brotli` and `zlib`
  support are all present.
- PECL and `php-pear` are **not** installed: PECL is deprecated, and PIE only had a release candidate of Swoole
  with `php-ext` metadata when this was decided.
- **`octane:8.6` is not published.** No Swoole release compiles against PHP 8.6 yet: v6.2.6, v6.3.0-rc2 and
  `master` all stop with `#error "require PHP version 8.5 or earlier"` (checked 2026-11-23). The
  `ubuntu/octane` Dockerfile on `main` is already on 8.6, but the `build-octane` job in `ci-ubuntu.yml` has
  `if: ${{ false }}`. When a stable Swoole supports 8.6, build it locally, then remove that line.
  Octane users stay on `octane:8.5` until then.
- Ondřej does not package Swoole for PHP 8.6 (he does package OpenSwoole 26.11 for 8.6, but switching
  extensions would change runtime behavior for Octane apps and is a separate decision).

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
- **8.6-slim is not published.** Alpine has no `php86` packages yet (checked 2026-11-23 on v3.24 and edge).
  On `main`, `ci-slim.yml` only runs on manual dispatch. When Alpine ships `php86`, verify the package list in
  `slim/*/Dockerfile` (extension names can change between Alpine PHP packages), restore the `push` and
  `schedule` triggers, and run it once by hand.
- The legacy `8.3-slim` branch publishes the same `8.3-slim` tags as the `8.3` branch's slim workflow, with
  older, known-broken Dockerfiles. Do not push to it; delete it once nobody depends on it.

## CI

| Workflow | Branches | Triggers | What it does |
|---|---|---|---|
| `ci-ubuntu.yml` | `main`, `8.5`, `8.4`, `8.3` | push to that branch, schedule (every 14 days), manual | builds and pushes `cli`, `fpm`, `octane`, `nginx` for amd64 + arm64 (octane job disabled on `main` for now) |
| `ci-slim.yml` | `8.5`, `8.4`, `8.3` (manual only on `main`) | push, schedule (monthly), manual | amd64 build + smoke test, then multi-arch push |
| `ci.yml` | `8.2` | push, manual | builds a `-candidate-<sha>` tag, verifies it on both arches, then promotes it |

Notes:

- Runners are `ubuntu-26.04`. This is the runner, not the image base; each image's base is its own `FROM`.
- **GitHub only runs `schedule` triggers on the default branch (`main`).** The version branches therefore only
  rebuild on push or manual dispatch; rebuild them by hand (`gh workflow run ci-ubuntu.yml --ref 8.5`) when a
  base image or PHP update should be picked up without a code change.
- Concurrency is per workflow and ref, with `cancel-in-progress: false`.
- arm64 builds run under QEMU emulation; the Swoole compile there takes about 20–25 minutes.
- Actions are kept current by Dependabot (`.github/dependabot.yml` on `main` lists every active branch as a
  target). Add new branches there.

## Starting a new PHP minor

What was done on 2026-11-23 for 8.6, as a checklist for next time:

1. Create the branch for the current minor from `main`:
   `git worktree add -b 8.5 ../dokar-php-8.5 main`.
2. On that branch, change the `push` trigger in `ci-ubuntu.yml` and `ci-slim.yml` from `main` to the branch name.
3. On `main`, replace the version everywhere (`8.5` → `8.6`, `php85` → `php86`), reset the guards to the new
   `.0` release, and move `FROM` to the newest Ubuntu LTS that packages.sury.org supports.
4. Check that every PHP package the Dockerfiles install exists for the new version on **both** architectures
   in packages.sury.org, and that Swoole compiles against it.
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
