# World Content

## Three separate layers

World and gameplay content is split across:

- `data/`
  - shared runtime and registries
- `data-canary/`
  - small custom world
- `data-otservbr-global/`
  - large production world

The actual world loaded at runtime depends on `dataPackDirectory`.

## Map composition model

Canary uses multiple content artifacts together:

- `.otbm`
  - map geometry
- `*-house.xml`
  - houses and house metadata
- `*-monster.xml`
  - monster spawn placement
- `*-npc.xml`
  - NPC spawn placement
- `*-zones.xml`
  - zone metadata

Main map load path:

- `${DATA_DIRECTORY}/world/${mapName}.otbm`

Optional custom map load path:

- `${DATA_DIRECTORY}/world/custom/*.otbm`
- loaded only when `toggleMapCustom` is enabled

The engine can also load additional map fragments at runtime with `Game::loadMap(...)`.

## `data-canary` world

The small datapack currently centers around:

- `data-canary/world/canary.otbm`
- matching `canary-house.xml`
- matching `canary-monster.xml`
- matching `canary-npc.xml`
- matching `canary-zones.xml`

Notes:

- this pack is intentionally light
- `canary-npc.xml` is minimal
- raids are mostly stub/example content

## `data-otservbr-global` world

Main world files:

- `data-otservbr-global/world/otservbr-house.xml`
- `data-otservbr-global/world/otservbr-monster.xml`
- `data-otservbr-global/world/otservbr-npc.xml`
- `data-otservbr-global/world/otservbr-zones.xml`

Alternate/custom world files:

- `data-otservbr-global/world/custom/otservbr-custom.otbm`
- matching `otservbr-custom-*.xml` files

Additional world fragments:

- `world/quest/**`
- `world/world_changes/**`
- `world/annual_events/**`

Those fragments are loaded by scripts and are part of the practical content system.

## Monster model

Monster content is split between:

- definition
  - `${DATA_DIRECTORY}/monster/**/*.lua`
- placement
  - `${DATA_DIRECTORY}/world/*-monster.xml`

Current scale:

- `data-canary`: 67 monster files
- `data-otservbr-global`: 1656 monster files

Typical monster definition responsibilities:

- stats
- flags
- attacks
- defenses
- elements
- immunities
- loot
- final registration into the monster type system

## NPC model

NPC content is also split between:

- definition
  - `${DATA_DIRECTORY}/npc/**/*.lua`
- placement
  - `${DATA_DIRECTORY}/world/*-npc.xml`

Current scale:

- `data-canary`: 1 NPC file
- `data-otservbr-global`: 1034 NPC files

NPC definitions rely on:

- shared `data/npclib/`
- Lua-side handlers and shop/dialog callbacks

## Raids

Raid registration is XML-based.

Examples:

- `data-canary/raids/raids.xml`
- `data-otservbr-global/raids/raids.xml`

OTServBR Global organizes raid files by region:

- `raids/abdendriel/`
- `raids/ankrahmun/`
- `raids/edron/`
- many more

Runtime linkage:

- global event hook in `data/scripts/globalevents/raids.lua`
- C++ raid support under `src/lua/creature/raids.*`
- raid startup during `GAME_STATE_INIT`

## Startup-only tables

`data-otservbr-global/startup/` is a special content layer.

Purpose:

- startup-only tables
- reserved action and unique ID mapping
- content that should not be treated as normal hot-reloadable scripts

Examples:

- door tables
- teleport tables
- chest tables
- tile tables
- writeable tables

The accompanying README documents reserved ranges for:

- level doors
- chests
- teleport items
- corpses
- tiles
- levers
- teleports
- item action/unique ranges

## Shared content systems

Shared content in `data/scripts/` includes:

- `globalevents/`
- `movements/`
- `runes/`
- `spells/`
- `systems/`
- registration helpers in `lib/`

These are not world-placement files, but they directly affect world behavior.

## Practical editing rules

When changing content, separate the concerns:

- geometry and map fragments:
  - `.otbm`
- entity placement:
  - `*-monster.xml`, `*-npc.xml`
- entity behavior:
  - monster or NPC Lua
- cross-cutting mechanics:
  - shared scripts under `data/scripts/`
- startup-only IDs and tables:
  - `data-otservbr-global/startup/`

If a change touches more than one of those layers, update them together.
