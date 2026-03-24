# Architecture

## Top-level design

Canary is a hybrid architecture:

- Composition boundary:
  - minimal DI container via Boost.DI
- Runtime access pattern:
  - many singleton-like global accessors such as `g_game()`, `g_configManager()`, `g_dispatcher()`, `g_database()`
- World execution model:
  - dispatcher-centered game logic
- Network model:
  - ASIO service manager plus protocol objects
- Content model:
  - strict C++ boot order feeding a large Lua and datapack layer

The codebase is not trying to be a pure clean-architecture refactor. Most large subsystems are still exposed through global accessors and shared runtime state.

## Entry point and composition

- `src/main.cpp`
  - process entrypoint
  - resolves `CanaryServer` from the DI container
- `src/lib/di/container.hpp`
  - binds a small set of services:
    - `AccountRepository -> AccountRepositoryDB`
    - `KVStore -> KVSQL`
    - `Logger -> LogWithSpdLog`
  - exposes `DI::create<T>()`, `DI::get<T>()`, and `inject<T>()`

## Major source areas

- `src/account/`
  - account model and repository abstraction
- `src/config/`
  - Lua-backed config loading and typed config access
- `src/creatures/`
  - players, monsters, NPCs, combat, appearance, grouping, vocations
- `src/game/`
  - central world authority, state transitions, scheduled gameplay tasks
- `src/io/`
  - application-facing persistence adapters
- `src/database/`
  - low-level MySQL layer, transactions, async DB tasks, schema versioning
- `src/items/`
  - item model, containers, tiles, thing hierarchy
- `src/lua/`
  - Lua environment, bindings, event systems, revscripts, modules
- `src/map/`
  - map representation, tile/spectator logic, towns, caching
- `src/server/`
  - service manager, signals, network messages, protocols, webhook
- `src/kv/`
  - scoped key-value store with SQL backend
- `src/lib/`
  - logging, DI helpers, metrics, thread pool, messaging

## Startup sequence

`src/canary_server.cpp` is the real bootstrap owner.

Startup flow:

1. Construct `CanaryServer`
2. Set game state to `GAME_STATE_STARTUP`
3. Initialize dispatcher
4. In `run()`, queue startup work on the dispatcher
5. Load config from `config.lua`
6. Validate datapack name unless `useAnyDatapackFolder = true`
7. Initialize optional metrics
8. Start RSA manager
9. Connect to MySQL and run schema updates
10. Load XML, Lua core, datapack scripts, monsters, NPCs, event schedulers
11. Set world type
12. Load main map and optional custom maps
13. Switch to `GAME_STATE_INIT`
14. Apply house/market post-load steps
15. Register network services and cyclic game tasks
16. Switch to `GAME_STATE_NORMAL` or `GAME_STATE_CLOSED`
17. Run ASIO service loop

Important detail: `run()` waits on a startup status with a 10-minute timeout. Startup is intentionally serialized and guarded.

## Module and content load order

The load order in `CanaryServer::loadModules()` is part of the architecture:

1. `appearances.dat`
2. XML:
   - `vocations.xml`
   - `outfits.xml`
   - `familiars.xml`
   - `imbuements.xml`
   - `storages.xml`
3. `items.xml`
4. shared core Lua:
   - `data/core.lua`
   - `data/scripts/lib`
   - `data/scripts`
   - `data/npclib`
5. shared XML event/module registries:
   - `data/events/events.xml`
   - `data/modules/modules.xml`
6. datapack Lua:
   - `${DATA_DIRECTORY}/scripts/lib`
   - `${DATA_DIRECTORY}/scripts`
   - `${DATA_DIRECTORY}/monster`
   - `${DATA_DIRECTORY}/npc`
7. event scheduler:
   - `data/XML/events.xml`
   - `data/json/eventscheduler/events.json`

If a future change needs a new asset or registry at startup, place it carefully in this sequence.

## Config model

- Config source is Lua, not JSON or YAML.
- `CanaryServer::loadConfigLua()` creates `config.lua` from `config.lua.dist` if needed.
- `ConfigManager::load()` executes the Lua file and stores values in typed maps.
- Some config is effectively startup-only; some can be reloaded via `SIGHUP`.

Important config anchors:

- `coreDirectory`
- `dataPackDirectory`
- `mapName`
- `gameProtocolPort`
- `loginProtocolPort`
- `statusProtocolPort`
- metrics toggles
- many gameplay feature flags and rate knobs

## Runtime authority

`Game` is the main world-state authority.

Responsibilities include:

- game state transitions
- world/map access
- creature registries
- item movement and placement
- player lookup and loading
- messaging/broadcasting
- market price cache refresh
- online player accounting
- map loading
- spawn and raid startup

`Game::start(ServiceManager*)`:

- registers `ProtocolGame`
- registers `ProtocolLogin`
- registers `ProtocolStatus`
- schedules recurring tasks for:
  - forgeable monster updates
  - light updates
  - creature checks
  - Lua garbage collection
  - market price refresh
  - online-player DB sync

## Game states

`Game::setGameState()` drives major lifecycle transitions.

- `GAME_STATE_INIT`
  - load market prices
  - load groups and chat channels
  - start monster and NPC spawns
  - load raids
  - load mounts and attached effects
  - load MOTD/player record
  - start global events
  - initialize wheel data
- `GAME_STATE_CLOSED`
  - save global state
  - remove non-privileged players
  - persist state
- `GAME_STATE_SHUTDOWN`
  - save global state
  - kick all players
  - persist state
  - schedule final shutdown

## Concurrency model

The safe mental model is:

- world logic lives on the dispatcher path
- the thread pool exists, but world mutation still needs to be marshalled back safely
- database tasks can run asynchronously, but callbacks return to the dispatcher
- network acceptors run through ASIO `io_service`

Practical implication:

- do not assume arbitrary background threads can safely mutate `Game`, `Player`, `Monster`, or map state
- Lua execution is tightly coupled to the runtime environment and guarded against unsafe nesting and shutdown

## Networking

`src/server/server.hpp` and `src/server/server.cpp` define:

- `ServiceManager`
  - owns ASIO `io_service`
  - owns signal handlers
  - owns acceptors keyed by port
- `ServicePort`
  - accepts TCP connections
  - multiplexes protocols on a port when allowed

Main protocol implementations:

- `src/server/network/protocol/protocolgame.*`
- `src/server/network/protocol/protocollogin.*`
- `src/server/network/protocol/protocolstatus.*`

Custom Lua-facing packet modules are configured separately through `data/modules/modules.xml`.

## Signals and reloads

`src/server/signals.cpp` maps OS signals into dispatcher work:

- `SIGINT`
  - shutdown
- `SIGTERM`
  - shutdown
- `SIGUSR1`
  - save global state
- `SIGHUP`
  - reload config
  - reload raids
  - reload items
  - reload mounts
  - reload events
  - reload chat channels
  - reload `core.lua`

This is a partial reload system, not a full runtime rebuild.

## Version and protocol anchors

- `src/core.hpp`
  - server release `3.4.2`
  - client version `1500`

Those values are useful when analyzing packet/protocol or compatibility work.
