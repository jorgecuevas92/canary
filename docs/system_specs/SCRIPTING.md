# Scripting

## Runtime model

Lua is a first-class runtime layer in Canary, not just a tiny extension system.

The server uses Lua for:

- gameplay systems
- spells, movements, runes, actions
- NPC and monster definitions
- custom packet modules
- event callbacks
- global events
- content migrations
- timed event scheduler scripts

## Main Lua engine pieces

- `src/lua/scripts/lua_environment.*`
  - owns the main Lua state
  - initializes built-in bindings
  - manages timer events and GC
- `src/lua/scripts/scripts.*`
  - recursive file loader for revscripts and event-scheduler scripts
- `src/lua/modules/modules.*`
  - custom packet module registry for recvbyte handlers
- `src/lua/callbacks/`
  - EventCallback infrastructure
- `src/lua/creature/`
  - actions, movement, creature events, raids, talkactions
- `src/lua/functions/`
  - C++ bindings exposed to Lua

## Load behavior

`Scripts::loadScripts()` recursively walks a folder and loads `.lua` files.

Important behavior:

- files prefixed with `#` are ignored
- library folders are loaded separately before normal script folders when requested
- console script logging is controlled by config

Startup order matters:

- shared core Lua first
- shared revscripts
- datapack libs
- datapack scripts
- monster definitions
- NPC definitions
- scheduler XML/JSON after revscripts

## Shared Lua boot files

- `data/core.lua`
  - loads:
    - `data/global.lua`
    - `data/libs/libs.lua`
    - `data/stages.lua`
- `data/global.lua`
  - loads datapack `lib/lib.lua`
  - conditionally loads datapack `startup/startup.lua`
  - defines global helper values and shared runtime tables

## Event systems

There are multiple event surfaces.

### Legacy XML event registry

- `data/events/events.xml`
- called out in its own header comment as a system being phased out

### EventCallback system

- documented in `data/scripts/eventcallbacks/README.md`
- supports callbacks for `Creature`, `Player`, `Party`, `Monster`, `Zone`, and map load
- supports `bool`, `void`, and `ReturnValue` callback semantics
- multiple callbacks can be registered for the same event

This is the preferred modern Lua-side callback surface.

### Global events

- shared global events live mostly under `data/scripts/globalevents/`
- datapack global events live under `${DATA_DIRECTORY}/scripts/globalevents/`

## Custom packet modules

- registry file: `data/modules/modules.xml`
- implementation: `src/lua/modules/modules.*`

Current registry examples include:

- gamestore handlers
- quest tracking
- daily reward wall
- hireling outfit helper

Model:

- a recv byte is declared in XML
- a Lua script handles `onRecvbyte`
- player-level delay throttling can apply

## Monsters and NPCs

Monster and NPC behavior is mostly Lua-defined.

Monster load path:

- shared registration helpers in `data/scripts/lib/`
- datapack monster files under `${DATA_DIRECTORY}/monster/**`

NPC load path:

- shared NPC framework under `data/npclib/`
- datapack NPC files under `${DATA_DIRECTORY}/npc/**`

Placement is separate from behavior:

- Lua defines the entity
- world XML defines where it spawns

## Event scheduler

The timed event scheduler has two data sources:

- XML: `data/XML/events.xml`
- JSON: `data/json/eventscheduler/events.json`

Implementation:

- `src/game/scheduling/events_scheduler.*`

Behavior:

- parses active date ranges
- can load an optional Lua script per scheduled event
- applies rates such as exp, loot, boss loot, spawn, skill
- stores extra runtime flags like forge chance or double bestiary in KV

The scheduler is shared-core content, not datapack-local in this checkout.

## Lua-based migrations

Two separate Lua migration ideas exist:

### DB migrations

- datapack-local numeric files in `${DATA_DIRECTORY}/migrations/`
- run by C++ database manager

### Game migrations

- registration helper: `data/scripts/lib/register_migrations.lua`
- execution state stored in KV under `migrations`
- meant for content/runtime data migrations outside raw SQL schema versioning

Naming rule enforced by `register_migrations.lua`:

- `<timestamp>_<description>`
- timestamp is expected to be 14 digits

## Safety notes

- Lua state is owned centrally; it is not safe to treat it as a casual background-worker API.
- Timer events, script environment, and call stack reservations are managed explicitly in C++.
- Reloading `core.lua` or individual data files does not mean every subsystem is safely recreated from scratch.
