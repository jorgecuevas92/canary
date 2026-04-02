# Persistence

## Storage model

Durable state in Canary is primarily MySQL-backed, with a mix of:

- normalized SQL tables
- binary blob serialization for large object graphs
- scoped KV storage for newer flexible systems

Static content is file-based and loaded from datapack assets. Mutable player and world state is SQL-backed.

## Core layers

### SQL transport layer

- `src/database/database.*`
  - low-level MySQL wrapper
  - escaping helpers
  - result handling
  - inserts and transactions
  - optional DB backup support

### Async DB execution

- `src/database/databasetasks.*`
  - runs DB work asynchronously
  - returns callbacks back to the dispatcher path

### Schema and version manager

- `src/database/databasemanager.*`
  - ensures DB is initialized
  - reads `server_config`
  - scans `${DATA_DIRECTORY}/migrations/*.lua`
  - executes pending migration scripts in numeric order
  - updates `db_version`

### Application-facing persistence

- `src/io/`
  - feature and entity persistence adapters

## Canonical schema

- `schema.sql`

Important facts:

- seeds `server_config`
- seeds `db_version = 54`
- defines major persistent tables for:
  - accounts
  - players
  - bans
  - VIP data
  - guilds
  - market
  - houses and tiles
  - storage maps
  - prey/bestiary/bosstiary/wheel-related systems
  - KV-backed systems

When making durable-state changes, `schema.sql` is only part of the work. You also need to check datapack migrations and loader/save code.

## Player persistence

Main entrypoint:

- `src/io/iologindata.*`

Responsibilities:

- account auth
- player load
- player save
- save transaction boundaries

The actual hydration and serialization are decomposed further in `src/io/functions/`.

Examples of loaded/saved data:

- core stats
- conditions
- outfits
- kills
- guild state
- stash and depot/inbox/reward inventories
- player storage map
- VIP data
- prey and task hunting
- bosstiary
- forge data
- wheel-related systems

## World and house persistence

Static world:

- loaded from OTBM plus XML files
- handled by `src/io/iomap.*`

Mutable house/tile state:

- persisted by `src/io/iomapserialize.*`
- stored through SQL rows and blob serialization

This means:

- geometry and base placement are file-based
- mutable house state is SQL-backed

## Feature-specific IO adapters

Important `src/io/` modules include:

- `ioguild.*`
- `iomarket.*`
- `iobestiary.*`
- `io_bosstiary.*`
- `ioprey.*`
- `io_wheel.*`
- `player_storage_repository_db.*`

Pattern:

- C++ gameplay objects do not talk directly to raw SQL everywhere
- feature-specific IO classes translate between game objects and SQL rows/blobs

## Serialization boundaries

Important files:

- `src/io/fileloader.*`
  - property stream readers/writers
- `src/io/iomap.*`
  - static map and companion XML loading
- `src/io/iomapserialize.*`
  - serialized mutable world storage

Large object graphs are often persisted as binary serialized payloads rather than fully normalized table sets.

Examples:

- inventories
- house tiles
- item attributes
- conditions

This is a key design constraint when evolving player or world persistence.

## KV store

Canary has a first-class scoped KV layer.

Important files:

- `src/kv/README.md`
- `src/kv/kv.*`
- `src/kv/kv_sql.*`
- `src/kv/value_wrapper_proto.*`
- `src/protobuf/kv.proto`

Characteristics:

- persistent
- thread-safe
- scoped namespaces
- SQL-backed in production
- Lua-exposed
- protobuf-backed value serialization

Good use cases:

- flexible feature flags
- per-system runtime state
- content/game migrations
- newer systems that do not fit nicely into rigid schema columns

## Migrations

### DB schema migrations

- located in `${DATA_DIRECTORY}/migrations/`
- numeric filenames
- executed by C++ database manager

Observed state in this checkout:

- `data-otservbr-global/migrations/1.lua` through `55.lua`
- `data-canary/migrations/` only contains documentation

### Game migrations

- registered via `data/scripts/lib/register_migrations.lua`
- execution state stored under KV scope `migrations`
- intended for content/runtime migrations beyond raw SQL versioning

## Metrics on persistence

Optional metrics can export:

- SQL query latency
- DB lock contention
- related runtime telemetry

Relevant files:

- `src/lib/metrics/metrics.*`
- `metrics/README.md`
- `metrics/docker-compose.yml`
- `metrics/prometheus/prometheus.yml`

## Practical change checklist

When changing persistent state:

1. check `schema.sql`
2. check `${DATA_DIRECTORY}/migrations/`
3. check `src/io/` load/save code
4. check whether the state should live in KV instead
5. check whether any blob serialization format is impacted
6. check tests for affected repositories or loaders
