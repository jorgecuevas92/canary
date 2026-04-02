# Canary Agent Guide

This repository is an Open Tibia Server named `Canary`. It is a hybrid C++ and Lua codebase with a strict bootstrap order, a large data-driven content layer, and a pragmatic mix of dependency injection plus global singleton-style accessors.

## What matters first

- `src/` is the C++ engine and server runtime.
- `data/` is the shared core Lua and XML layer used by every datapack.
- `data-canary/` is the small custom datapack.
- `data-otservbr-global/` is the full production datapack and the default one in `config.lua.dist`.
- `tests/` contains C++ unit and integration tests, plus standalone Lua tests under `tests/lua/`.
- `docs/system_specs/` contains the generated system notes for this repository snapshot.

## Safe mental model

- Entry point: `src/main.cpp` resolves `CanaryServer` from the DI container and calls `run()`.
- Startup authority: `src/canary_server.cpp` owns config loading, datapack validation, database init, Lua/module loading, world type selection, map loading, and server start.
- Runtime authority: `Game`, `Dispatcher`, and `ServiceManager` are the main control points.
- Persistence authority: `src/io/` is the application-facing persistence layer; `src/database/` is the SQL transport/transaction layer.
- Content authority: gameplay behavior is heavily Lua-driven, but the C++ load order is strict and easy to break if changed casually.

## High-risk areas

- Do not reorder the startup sequence in `CanaryServer::loadModules()` unless you understand every downstream dependency.
- Do not move content between `data/` and a datapack directory casually:
  - `data/` is shared core/runtime infrastructure.
  - `data-canary/` and `data-otservbr-global/` are content packs.
- `data-otservbr-global/startup/` is for startup-only tables and non-reloadable metadata. Treat it as boot-time state, not normal hot-reload content.
- Reload support is partial:
  - `SIGHUP` reloads config, raids, items, mounts, events, channels, and `core.lua`.
  - it does not recreate the entire server state cleanly.
- Many gameplay paths assume dispatcher-thread execution. Async work must return to the dispatcher before mutating world state.

## Practical editing rules

- Prefer constructor injection when extending top-level systems, but expect existing code to use `g_*()` globals and `inject<T>()`.
- When editing Lua content, decide first whether the change belongs in:
  - shared core `data/`
  - minimal datapack `data-canary/`
  - full datapack `data-otservbr-global/`
- When changing persistent player/world state:
  - inspect `schema.sql`
  - inspect `${DATA_DIRECTORY}/migrations/`
  - inspect `src/io/` save/load code
  - inspect whether KV storage is a better fit than a new fixed SQL column
- When changing network or packet behavior:
  - inspect `src/server/network/protocol/`
  - inspect `data/modules/modules.xml`
  - inspect Lua module handlers in `data/modules/`
- When changing scripts, remember the loader ignores files prefixed with `#`.

## Build and test

Recommended CMake presets:

```bash
cmake --preset linux-debug
cmake --build --preset linux-debug
ctest --preset linux-debug
ctest --preset linux-debug -R unit
ctest --preset linux-debug -R integration
```

Lua tests are separate:

```bash
luajit tests/lua/test_npc_messaging.lua
```

Useful local helpers:

- `start.sh`: starts the built server, creates `config.lua` from `config.lua.dist` if missing, writes logs.
- `recompile.sh`: Linux-oriented convenience wrapper around preset-based CMake builds.
- `docker/docker-compose.yml`: local MariaDB + server + login stack.

## Where to read next

- `docs/system_specs/README.md`
- `docs/system_specs/ARCHITECTURE.md`
- `docs/system_specs/DEVELOPMENT.md`
- `docs/system_specs/DATAPACKS.md`
- `docs/system_specs/SCRIPTING.md`
- `docs/system_specs/WORLD_CONTENT.md`
- `docs/system_specs/PERSISTENCE.md`
- `docs/system_specs/TESTING.md`
