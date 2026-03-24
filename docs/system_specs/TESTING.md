# Testing

## Test surfaces

Canary has three practical test layers:

- C++ unit tests
- C++ integration tests
- standalone Lua tests

## Build-time structure

Tests are enabled with `CANARY_BUILD_TESTS=ON`.

When enabled:

- the core code is built as static library `canary_core`
- unit and integration executables link against `canary_core`

Relevant files:

- `src/CMakeLists.txt`
- `tests/CMakeLists.txt`

## Running tests

Recommended:

```bash
cmake --preset linux-debug
cmake --build --preset linux-debug
ctest --preset linux-debug
```

Filter by suite:

```bash
ctest --preset linux-debug -R unit
ctest --preset linux-debug -R integration
```

Direct executables:

```bash
./build/linux-debug/tests/unit/canary_ut
./build/linux-debug/tests/integration/canary_it
```

Lua tests:

```bash
luajit tests/lua/test_npc_messaging.lua
```

CI runs Lua tests by iterating `tests/lua/test_*.lua` directly with `luajit`.

## Frameworks and style

### C++

The repository uses:

- GoogleTest for executable/test discovery wiring
- Boost::ut style guidance is still documented in `tests/README.md`

The main point for contributors is that tests are ordinary C++ executables linked against `canary_core`.

### Lua

Lua tests are lightweight scripts, independent from CTest.

## Test layout

- `tests/unit/`
  - unit suites
- `tests/integration/`
  - integration suites
- `tests/fixture/`
  - DI/test doubles/helpers
- `tests/shared/`
  - shared fixtures and helpers
- `tests/lua/`
  - direct Lua tests

Representative areas already covered:

- account repository
- event callbacks
- event scheduler
- imbuements
- KV
- RSA/security
- player storage repository
- utility functions

## DI test container

Tests rely heavily on swapping the production DI bindings.

Important files:

- `src/lib/di/container.hpp`
- `tests/fixture/injection_fixture.hpp`
- `tests/unit/main.cpp`
- `tests/integration/main.cpp`

Unit test bootstrap:

- installs in-memory logger
- sets the DI test container
- initializes logger/config/database singletons

Integration test bootstrap:

- installs in-memory logger
- installs in-memory KV
- installs test Lua environment
- initializes test database

This makes the DI container the main seam for replacing infrastructure in tests.

## Test database

Integration tests have dedicated DB support:

- `tests/Dockerfile.database`
- `tests/docker-compose.yaml`
- `tests/integration/test_database.hpp`

The repository includes a simple MariaDB-based integration test stack for local runs.

## What to test when changing code

Engine/runtime changes:

- add or update unit tests around the changed C++ subsystem
- add integration tests if the change touches DB, Lua, or dispatcher behavior

Persistence changes:

- verify repository or loader/save tests
- add integration coverage for schema or IO changes

Lua/content changes:

- add or update Lua tests when the behavior can be isolated
- add integration coverage when content interacts with C++ persistence or callbacks

## Known practical limitation

Not every content-heavy path has deep automated coverage. Large datapack changes can still require manual runtime validation in addition to tests.
