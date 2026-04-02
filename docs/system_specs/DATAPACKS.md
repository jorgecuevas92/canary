# Datapacks

## The split is intentional

Canary does not have a single monolithic `data/` folder.

It has three layers:

- `data/`
  - shared engine-facing Lua/XML infrastructure
- `data-canary/`
  - small custom datapack
- `data-otservbr-global/`
  - large full production datapack

Default runtime selection in `config.lua.dist`:

- `coreDirectory = "data"`
- `dataPackDirectory = "data-otservbr-global"`

Unless `useAnyDatapackFolder = true`, startup only accepts `data-canary` or `data-otservbr-global`.

## What lives in `data/`

`data/` is the shared runtime foundation, not a normal content pack.

Important contents:

- `data/core.lua`
  - bootstraps `data/global.lua`, `data/libs/libs.lua`, and `data/stages.lua`
- `data/global.lua`
  - loads `${DATA_DIRECTORY}/lib/lib.lua`
  - conditionally loads `${DATA_DIRECTORY}/startup/startup.lua`
- `data/XML/`
  - shared XML registries such as vocations, outfits, familiars, mounts, imbuements, storages, and scheduler XML
- `data/events/events.xml`
  - legacy XML event callback registry
- `data/modules/modules.xml`
  - recvbyte-to-Lua module registry
- `data/items/`
  - `appearances.dat` and `items.xml`
- `data/npclib/`
  - base NPC framework
- `data/scripts/`
  - shared revscripts, systems, spells, runes, globalevents, movements, helpers
- `data/json/eventscheduler/`
  - JSON-driven timed event schedule

Rule of thumb:

- if the file is engine-shared and should work with any datapack, it probably belongs in `data/`
- if the file is world/content specific, it probably belongs in a datapack

## `data-canary`

This is the lightweight datapack.

Current scale:

- 107 files total
- 67 monster files
- 1 NPC file

Characteristics:

- small `lib/` layer
- a few scripts
- one main map
- minimal NPC setup
- minimal raids
- migration directory is documentation-only in this checkout

Important files:

- `data-canary/lib/lib.lua`
  - only loads `lib/core/load.lua`
- `data-canary/world/canary.otbm`
- `data-canary/world/canary-house.xml`
- `data-canary/world/canary-monster.xml`
- `data-canary/world/canary-npc.xml`
- `data-canary/world/canary-zones.xml`
- `data-canary/raids/raids.xml`

This pack is the cleaner, smaller target when you want a narrow custom server or a simpler content surface.

## `data-otservbr-global`

This is the large production datapack and the default one.

Current scale:

- 4747 files total
- 1656 monster files
- 1034 NPC files
- 978 quest script files
- 55 numbered DB migration files in `migrations/`

Important structure:

- `lib/`
  - `core/`, `others/`, `quests/`, `tables/`, `functions/`
- `monster/<family>/...`
  - per-monster Lua definitions
- `npc/` and `npc/<region>/...`
  - per-NPC Lua definitions
- `scripts/`
  - actions, creaturescripts, movements, globalevents, raids, quests, systems, world_changes, custom content
- `startup/`
  - boot-time tables and startup-only functions
- `migrations/`
  - numeric DB migration sequence
- `world/`
  - main world files and custom world variant

## How bootstrapping works across the split

1. C++ loads `data/core.lua`
2. `data/core.lua` loads `data/global.lua`
3. `data/global.lua` loads `${DATA_DIRECTORY}/lib/lib.lua`
4. if present, `${DATA_DIRECTORY}/startup/startup.lua` is executed
5. shared `data/` revscripts and registries load
6. datapack revscripts, monsters, NPCs, and migrations load

This means datapacks extend the shared core layer rather than replacing it.

## Startup-only content

Only `data-otservbr-global` has a dedicated `startup/` tree in this checkout.

Purpose:

- tables loaded once at startup
- reserved action ID and unique ID ranges
- content that is not expected to hot-reload cleanly

Read `data-otservbr-global/startup/README.md` before editing those tables.

## Migrations

Two migration systems exist:

### Database migrations

- path: `${DATA_DIRECTORY}/migrations/*.lua`
- executed by `DatabaseManager`
- ordered numerically
- update `server_config.db_version`

### Game migrations

- registered through `data/scripts/lib/register_migrations.lua`
- execution state stored in KV under `migrations`
- intended for Lua/content migrations beyond raw schema upgrades

## Practical placement rules

Put a change in `data/` when:

- it is shared infrastructure
- it is an engine-facing XML registry
- it is a global helper or shared revscript system

Put a change in `data-canary/` or `data-otservbr-global/` when:

- it is map-specific
- it is world-content specific
- it is quest, raid, NPC, monster, or region content
- it relies on datapack-only assets or startup tables

Avoid duplicating logic into both datapacks unless the divergence is deliberate.
