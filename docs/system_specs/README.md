# Canary System Specs

Snapshot generated from repository analysis on 2026-03-24.

## Repository snapshot

- `src/`: 477 files
- `data/`: 649 files
- `data-canary/`: 107 files
- `data-otservbr-global/`: 4747 files
- `tests/`: 63 files

Default runtime facts taken from source:

- Server release: `3.4.2`
- Client version: `15.00`
- Default datapack: `data-otservbr-global`
- Shared core directory: `data`

## What this project is

Canary is a C++ MMORPG server emulator with a large Lua-driven content layer. It is not a pure-engine-only server and it is not a pure-script-only server. The engine, network stack, database layer, loader order, and game state authority are in C++, while most gameplay content and a large amount of behavior live in Lua and datapack files.

## Reading order

- `ARCHITECTURE.md`
  - Engine layout, bootstrap flow, DI model, lifecycle, networking, scheduler model.
- `DEVELOPMENT.md`
  - Build presets, dependencies, Docker, metrics, common workflows, repo conventions.
- `DATAPACKS.md`
  - Why `data/`, `data-canary/`, and `data-otservbr-global/` are separate and how they boot.
- `SCRIPTING.md`
  - Lua environment, revscript loading, EventCallback, modules, scheduler events, game migrations.
- `WORLD_CONTENT.md`
  - Maps, spawns, NPCs, monsters, raids, startup tables, content composition.
- `PERSISTENCE.md`
  - SQL schema, migrations, player/world saving, IO layer, KV, serialization.
- `TESTING.md`
  - Unit, integration, and Lua tests plus how the DI test container works.

## Fast mental model

- `src/main.cpp` creates `CanaryServer` through Boost.DI and calls `run()`.
- `CanaryServer` owns startup ordering.
- `Game` owns world state and gameplay authority.
- `Dispatcher` is the central execution path for timed and deferred game work.
- `ServiceManager` owns ASIO acceptors and network services.
- `src/io/` translates gameplay state to and from SQL.
- `data/` is shared engine-facing Lua/XML infrastructure.
- `data-otservbr-global/` is the real full content pack.

## Useful top-level files

- `README.md`: public project overview.
- `CMakeLists.txt` and `CMakePresets.json`: build entrypoints.
- `config.lua.dist`: default runtime config surface.
- `schema.sql`: canonical schema bootstrap.
- `vcpkg.json`: dependency manifest.
- `.github/workflows/`: CI split across checks, Lua tests, native builds, Docker builds.
