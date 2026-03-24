# Docker

## Requirements

- Docker Engine
- Docker Compose v2

Run the commands in this guide from the `docker/` directory unless noted
otherwise.

## What the current compose file does

`docker-compose.yml` defines three services:

- `database`
  - MariaDB
  - imports `../schema.sql` on the first startup of an empty volume
- `login`
  - the external login service
  - exposes HTTP on `8080` and gRPC on `9090`
- `server`
  - builds Canary from `docker/Dockerfile.dev`

## Recommended local usage

For contributor work, the practical path is:

- use Docker for `database` and `login`
- build and run the `canary` server binary natively from the repository root

The Docker commands in this file are generally portable, but the native build
commands shown alongside them were validated on Ubuntu/Linux. Windows users
should not assume the same host-native setup steps apply unchanged.

One-time setup:

```bash
cp .env.dist .env
docker compose up -d database login
```

Then, from the repository root:

```bash
cmake --preset linux-release
cmake --build --preset linux-release
./canary
```

This keeps the stateful services reproducible without forcing every local edit
and rebuild through Docker.

## Why the native server is the default local recommendation

The compose-defined `server` service builds through `docker/Dockerfile.dev`.
That Dockerfile expects the vcpkg feed configuration used by CI, including a
`github_token` build secret. If you do not already have that setup, `server`
is not the smoothest first-time local workflow.

Use the `server` service when you explicitly want to validate the containerized
build path or when you already have the required feed credentials.

## Login and bootstrap credentials

Default local endpoints:

- login URL: `http://127.0.0.1:8080/login.php`
- login gRPC: `127.0.0.1:9090`
- game server: `127.0.0.1:7172`
- login protocol: `127.0.0.1:7171`

The bootstrap schema creates a default account:

- email/login: `@god`
- password: `god`

If your client expects an account name instead of an email, try `god` /
`god`.

The bootstrap account includes the sample characters from `schema.sql`.

## Optional sample test accounts

If you want the extra bundled test accounts and characters:

```bash
docker compose exec -T database mariadb -uroot -proot otservbr-global < data/01-test_account.sql
docker compose exec -T database mariadb -uroot -proot otservbr-global < data/02-test_account_players.sql
```

These add accounts like `test1`, `test2`, and `dawn`. The bundled password hash
matches `test`.

## Useful commands

```bash
docker compose ps
docker compose logs -f database login
docker compose down
```

To reset the database volume completely:

```bash
docker compose down -v
```

Remember that `schema.sql` is imported automatically only on the first startup
of a fresh database volume.
