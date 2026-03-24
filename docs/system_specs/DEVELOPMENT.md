# Development

## Toolchain

Build system:

- CMake
- Ninja via presets
- vcpkg for dependency resolution

Important preset assumption:

- `VCPKG_ROOT` must point to a bootstrapped local `vcpkg` checkout before
  running `cmake --preset ...`
- the host-native workflow documented below was validated on Ubuntu/Linux
- Windows and macOS have separate presets, but the step-by-step bootstrap in
  this document is not meant to be copied verbatim to those platforms

Key files:

- `CMakeLists.txt`
- `src/CMakeLists.txt`
- `tests/CMakeLists.txt`
- `CMakePresets.json`
- `vcpkg.json`

Core third-party dependencies from `vcpkg.json`:

- `asio`
- `libmariadb`
- `luajit`
- `protobuf`
- `pugixml`
- `spdlog`
- `openssl`
- `argon2`
- `nlohmann-json`
- `parallel-hashmap`
- `bext-di`
- `gtest`
- optional `opentelemetry-cpp` via the `metrics` feature

`package.json` is metadata only. There is no real JavaScript build pipeline here.

Typical Linux prerequisites for the documented presets:

- CMake 3.24 or newer
- Ninja
- Git
- GCC/G++ 11 or newer
- a bootstrapped `vcpkg` checkout exported as `VCPKG_ROOT`
- Docker with Compose v2 if you want local DB and login services

One-time `vcpkg` bootstrap example:

```bash
git clone https://github.com/microsoft/vcpkg.git "$HOME/vcpkg"
"$HOME/vcpkg/bootstrap-vcpkg.sh"
export VCPKG_ROOT="$HOME/vcpkg"
```

If you are on Windows, use the `windows-release` or `windows-debug` presets
instead of the Linux commands shown below, and expect the surrounding toolchain
setup to differ.

## Recommended build commands

From the repository root:

```bash
cmake --preset linux-release
cmake --build --preset linux-release
./canary
```

Other useful presets:

- `linux-release`
- `linux-debug`
- `linux-release-enabled-tests`
- `linux-debug-asan`
- `windows-release`
- `windows-debug`
- `macos-release`
- `macos-debug`
- metrics-enabled release variants for each platform

## Test build shape

When `CANARY_BUILD_TESTS=ON`:

- C++ core code is built as static library `canary_core`
- tests link against `canary_core`
- the server executable can still be built separately

When tests are off:

- the core is folded directly into the main executable

This split matters when refactoring compile units or link dependencies.

## Common local workflows

### Native debug build

```bash
cmake --preset linux-debug
cmake --build --preset linux-debug
ctest --preset linux-debug -VV
```

### Linux release build

```bash
cmake --preset linux-release
cmake --build --preset linux-release
./canary
```

### Recommended contributor workflow

Use Docker for the stateful services and run the server natively:

```bash
cd docker
cp .env.dist .env
docker compose up -d database login

cd ..
cmake --preset linux-release
cmake --build --preset linux-release
./canary
```

This exact host-native workflow was verified on Ubuntu/Linux.

### Helper scripts

- `recompile.sh`
  - convenience script for Linux builds
  - wraps configure/build and copies the built binary to the repo root
- `start.sh`
  - runs the server binary
  - creates `config.lua` from `config.lua.dist` if missing
  - timestamps logs into `logs/`
  - best suited to containerized runs because it also rewrites `config.lua`
    from `docker/.env`

## Runtime config workflow

- `config.lua.dist` is the template
- the runtime file is `config.lua`
- on first start, the server copies the dist file if `config.lua` does not exist
- for a first host-native launch, prefer `./canary` over `./start.sh`

Important default decisions:

- `coreDirectory = "data"`
- `dataPackDirectory = "data-otservbr-global"`
- `useAnyDatapackFolder = false`

Do not assume a config change is hot-reloadable just because it exists in Lua.

## Docker and local services

`docker/docker-compose.yml` starts:

- `database`
  - MariaDB seeded from `schema.sql`
- `server`
  - Canary via `docker/Dockerfile.dev`
- `login`
  - external login service container

For contributor work, the low-friction path is usually `database` + `login`
from Docker Compose plus a native server build. The compose-defined `server`
service is useful when you specifically want the containerized server build,
but `docker/Dockerfile.dev` expects the vcpkg feed configuration used by CI,
so it is not the simplest first-time local path.

The Docker services themselves are not Linux-specific, but the native build and
run commands shown in this document are.

## Bootstrap login

With the default config:

- host: `127.0.0.1`
- login port: `7171`
- game port: `7172`
- login URL when the `login` service is running: `http://127.0.0.1:8080/login.php`

The bootstrap database in `schema.sql` creates the default account `@god` /
`god` and sample characters on that account.

## Metrics

Metrics are optional and guarded behind `FEATURE_METRICS`.

To enable Prometheus export in `config.lua`:

```lua
metricsEnablePrometheus = true
metricsPrometheusAddress = "0.0.0.0:9464"
```

`metrics/docker-compose.yml` provides a Prometheus + Grafana setup for local inspection.

## CI model

CI is split across reusable workflows:

- fast checks
- Lua tests
- Linux build
- Windows build
- macOS build
- Docker build

Lua tests are simple `luajit tests/lua/test_*.lua` executions in CI. They are
not driven through CTest.

## Coding conventions that matter here

- Prefer CMake presets over ad hoc local commands.
- Prefer `data/` only for shared engine/runtime Lua or XML, not datapack-only content.
- Respect the dispatcher/thread-pool split. Async work must not casually mutate world state.
- Preserve load ordering in startup code.
- Preserve startup-only semantics in `data-otservbr-global/startup/`.
- Treat config reload and `/reload` as limited support features, not a promise of full hot-reload safety.

## Good change checklist

Before changing a subsystem, inspect the matching layers:

- Engine/bootstrap change:
  - `src/canary_server.cpp`
  - `src/game/game.cpp`
  - `src/server/`
- Lua or content change:
  - `data/`
  - the active datapack
  - `docs/system_specs/DATAPACKS.md`
- Persistence change:
  - `schema.sql`
  - `src/io/`
  - `src/database/`
  - datapack `migrations/`
  - `docs/system_specs/PERSISTENCE.md`
- Test-affecting change:
  - `tests/`
  - `tests/fixture/`
  - `docs/system_specs/TESTING.md`
