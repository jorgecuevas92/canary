---
name: npc-creator
description: Creates or updates Canary NPCs in data-canary or data-otservbr-global, including requirement discovery, trader or service classification, Lua NPC behavior, and matching world *-npc.xml spawn placement. Use when adding a merchant, trader, quest NPC, captain, trainer, or other NPC for this repository.
---

# NPC Creator

You are creating NPCs for the Canary repository.

## When to Use

Use this skill when:

- the user asks to add, update, or design an NPC
- the request involves a merchant, trader, captain, trainer, quest giver, addon NPC, token exchanger, or dialog NPC
- the request is ambiguous about whether a new NPC is needed or whether an existing NPC should absorb the responsibility

## Start With Discovery

Do not jump straight to implementation unless the request is already specific enough.

Start by understanding why the NPC should exist. Ask only for the missing facts, and keep the first clarification message short. If there are many unknowns, ask the 2-4 highest-signal questions first instead of dumping a large questionnaire.

Prioritize these questions:

1. Why does this NPC need to exist?
   - What player problem, quest need, economy gap, tutorial step, or worldbuilding purpose does it solve?
   - Could an existing NPC own this instead?
2. What responsibilities should this NPC have?
   - Keep one primary responsibility and only a small number of secondary services.
3. Which datapack should own it?
   - `data-canary/` for minimal or custom content.
   - `data-otservbr-global/` for production or broad world content.
4. Where should it spawn?
   - Ask for the town, area, exact coordinates if they are not already known, and whether the world XML should be updated now.
5. What restrictions apply?
   - Quest storage, vocation, level, premium status, date or time, reputation, world state, or one-time unlock.
6. If it trades, what are the shop rules?
   - Inventory, buy prices, sell prices, currency, categories, gating, and any special item counts or subtypes.
   - Clarify direction when the user says "sell price" or "buy price" in natural language:
     - `buy` means the player buys from the NPC.
     - `sell` means the NPC buys from the player.

If the user only gives a theme, propose a small set of responsibility options and recommend one. Do not invent a broad NPC with too many unrelated duties just because the request is vague.

## Trader Types

The most common trader is a standard gold-based buy or sell NPC, but this repository supports several trader archetypes. Identify which one fits before coding:

- Standard trader: normal buy or sell shop, usually the default choice.
- Buy-only supplier: players buy items from the NPC, but the NPC does not buy back loot.
- Sell-only loot buyer: the NPC exists mainly to buy loot or valuables from players.
- Buy and sell merchant: the common "general shop" pattern.
- Category trader: one NPC exposes filtered shop subsets such as runes, wands, or equipment groups.
- Gated trader: some or all offers unlock behind storages or quest progress.
- Alternative-currency trader: uses `npcConfig.currency` instead of gold.
- Traveling or recognized trader: trade access depends on time, location, or reputation.
- Hybrid trader: mixes a shop with travel, enchantment, addon exchange, quest logic, or another service.
- Reward or exchange trader: token, addon, charge, or outfit exchange with custom dialog.

Default to the smallest fitting type. If the user does not ask for a special economy or unlock flow, prefer a simple trader.

## Canary Source Of Truth

Read and follow these files when the task needs them:

- `AGENTS.md`
- `docs/system_specs/DATAPACKS.md`
- `docs/system_specs/WORLD_CONTENT.md`
- `docs/system_specs/SCRIPTING.md`
- `data/scripts/lib/register_npc_type.lua`
- `data/npclib/npc_system/modules.lua`

Representative NPC examples:

- Simple trader and mixed dialog: `data-canary/npc/canary.lua`
- Simple shopkeeper: `data-otservbr-global/npc/ninos.lua`
- Category trader: `data-otservbr-global/npc/frans.lua`
- Fixed-position merchant or service NPC: `data-otservbr-global/npc/inkaef.lua`
- Quest-gated shop entries: `data-otservbr-global/npc/gnomux.lua`
- Alternative-currency trader with extra services: `data-otservbr-global/npc/cledwyn.lua`
- Travel plus shop hybrid: `data-otservbr-global/npc/captain_max.lua`
- Traveling or recognized trader: `data-otservbr-global/npc/rashid.lua`

## Process

1. Clarify necessity and responsibilities.
2. Choose the datapack and confirm whether a new NPC is correct.
3. Inspect 2-3 nearby examples in the same datapack and role.
4. Choose the simplest implementation pattern that satisfies the request.
5. Implement the NPC Lua definition.
6. Update NPC spawn placement in the matching world XML.
7. Validate behavior, economy assumptions, and naming consistency.

## Implementation Rules

### Pick the right datapack

- Prefer `data-canary/` when the change is custom, minimal, or for the stripped-down pack.
- Prefer `data-otservbr-global/` when the NPC belongs to the production content set.
- Do not place shared framework changes in a datapack unless the behavior is datapack-specific.

### Remember behavior vs placement

NPC content is split in two places:

- behavior: `${DATA_DIRECTORY}/npc/**/*.lua`
- placement: `${DATA_DIRECTORY}/world/*-npc.xml`

Do not stop after adding the Lua file if the user expects the NPC to exist in the world. The usual pair is:

- `data-canary/npc/<name>.lua` and `data-canary/world/canary-npc.xml`
- `data-otservbr-global/npc/<name>.lua` and `data-otservbr-global/world/otservbr-npc.xml`

One Lua definition can be reused for multiple city spawns when behavior, inventory, and dialog are identical. Do not clone city-specific variants unless the cities genuinely need different NPC behavior or names.

If the exact spawn position is unknown and cannot be inferred safely, stop and ask for coordinates instead of inventing them.

Be conservative about "safe inference". Guide map marks, depot rectangles, or nearby NPCs can narrow an area, but they usually do not identify an exact "main entrance" tile safely enough for spawn placement on their own.

If coordinates come from CSV or prose, normalize small formatting issues such as whitespace, quotes, or trailing punctuation before treating the input as invalid.

### Reuse the shared NPC framework

Most NPCs in this repository follow this structure:

1. `Game.createNpcType(...)`
2. `npcConfig` fields such as name, outfit, walk settings, flags, voices, and shop
3. `KeywordHandler` and `NpcHandler`
4. standard callback wiring for think, appear, disappear, move, say, and close channel
5. custom dialog callbacks only when needed
6. `npcType:register(npcConfig)`

Prefer shared helpers over custom logic when they fit:

- `StdModule.say`
- `StdModule.travel`
- `StdModule.promotePlayer`
- `StdModule.learnSpell`
- `StdModule.bless`

Use custom dialog state only for genuinely custom quest or service behavior.

If the NPC must stay on one exact tile, set both:

- `npcConfig.walkInterval = 0`
- `npcConfig.walkRadius = 0`

### Keep responsibilities focused

- If the NPC is mainly a trader, keep side features limited.
- If the NPC is mainly a quest NPC, only add trade when it directly supports the quest or the setting.
- Avoid creating one NPC that is simultaneously a shopkeeper, travel NPC, trainer, addon NPC, and quest hub unless the user explicitly wants that complexity.

### Use the shop system deliberately

For straightforward shops, prefer `npcConfig.shop = { ... }` plus the standard buy and sell callbacks.

Supported shop features in this repo include:

- `itemName`
- `clientId`
- `buy`
- `sell`
- `count`, `subType`, or `subtype`
- `storageKey`
- `storageValue`
- `child` for nested shop entries
- `npcConfig.currency` for non-gold trades

Important semantics in this repo:

- `buy`: player buys from the NPC
- `sell`: NPC buys from the player

When the source inventory provides item ids, prefer resolving canonical item names from `data/items/items.xml` instead of trusting external spelling. This avoids mismatches like casing, apostrophes, pluralization, or datapack-specific aliases in `itemName`.

Before inventing prices, search existing NPCs for the same item. Keep the economy coherent and avoid accidental arbitrage. The shared registration code already warns when an item's global sell price exceeds a global buy price.

### Trader selection heuristics

- Use a simple buy and sell table for ordinary merchants.
- Use category-based shop windows when the inventory is large or naturally grouped.
- Use `storageKey` and `storageValue` when only certain offers should unlock after progress.
- Use `npcConfig.currency` when the user clearly wants tokens or another item-based currency.
- Use trade callbacks or `CALLBACK_ON_TRADE_REQUEST` when access itself must be restricted.
- Use travel helpers when the NPC is a captain or ferryman, not custom teleport code, unless an existing pattern clearly requires custom handling.

## Validation

Before finishing:

- confirm the NPC file path matches the intended datapack
- confirm `npcConfig.name` matches the world XML spawn entry name
- confirm the NPC is registered with `npcType:register(npcConfig)`
- confirm shop entries use valid item names or ids and the right buy or sell direction
- confirm fixed-position NPCs use both `walkInterval = 0` and `walkRadius = 0`
- confirm storage gates reference real quest or storage constants
- confirm currency-based traders use the correct token item id
- confirm topic state resets cleanly after yes or no branches
- confirm the world XML was updated when the NPC is meant to spawn in the world

Useful check from repo guidance:

```bash
luajit tests/lua/test_npc_messaging.lua
```

Run it when the change touches NPC messaging behavior and the test is relevant. If you cannot validate a point, say so explicitly.

If `luajit` is unavailable locally, fall back to the strongest checks you can still perform and say what was missing. At minimum:

- inspect canonical item names in `data/items/items.xml` when shop data came from external files
- verify `npcConfig.name` and world XML spawn names match
- verify the spawn file contains every expected location
- verify fixed-tile settings when the NPC must not move

## Output Expectations

When the user asks for implementation:

- summarize the NPC's reason for existing
- state the chosen NPC type and why it fits
- note the datapack and world XML touched
- call out any assumptions that still need map or design confirmation

When the user asks for design only:

- return a short responsibility proposal
- identify the recommended trader type, if any
- list the minimum missing information needed before implementation
