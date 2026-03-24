## Testing

### Running tests

The CMake test presets assume an external `vcpkg` checkout is already
available through `VCPKG_ROOT`. If `VCPKG_ROOT` is unset, the preset configure
step fails before the build starts.

The concrete setup commands in this section were validated on Ubuntu/Linux.
Windows and macOS users should use the matching platform presets and adapt the
host toolchain setup accordingly.

One-time `vcpkg` bootstrap example:

```bash
git clone https://github.com/microsoft/vcpkg.git "$HOME/vcpkg"
"$HOME/vcpkg/bootstrap-vcpkg.sh"
export VCPKG_ROOT="$HOME/vcpkg"
```

For Linux integration tests, you also need a database available at
`127.0.0.1:3306` with the `otservbr-global` schema. The simplest local setup is
the bundled Docker database service:

```bash
cd docker
cp .env.dist .env
docker compose up -d database
docker compose exec -T database mariadb -uroot -proot otservbr-global < data/01-test_account.sql
docker compose exec -T database mariadb -uroot -proot otservbr-global < data/02-test_account_players.sql
cd ..
```

Tests can then be run directly from the repository root using CMake test
presets. First, configure and build tests for your platform:

```bash
# Configure and build tests
cmake --preset linux-debug && cmake --build --preset linux-debug

# Run all tests
ctest --preset linux-debug

# Run only unit tests
ctest --preset linux-debug -R unit

# Run only integration tests
ctest --preset linux-debug -R integration

# Use -VV for verbose output showing individual test cases
ctest --preset linux-debug -VV
```

Replace `linux-debug` with `macos-debug` or `windows-debug` for other platforms.

#### Direct executable access

You can also run test executables directly if needed:

```bash
./build/linux-debug/tests/unit/canary_ut
./build/linux-debug/tests/integration/canary_it
```

### Adding tests

Tests are added in the `tests` folder, in the root of the repository.
As much as possible, tests should be added in the same folder as the code they are testing:

```
- src
    - foo
        - foo.cpp
    - bar
        - bar.cpp
- tests
    - foo
        - foo_test.cpp
    - bar
        - bar_test.cpp
```

### Boost::ut

Tests are written using the Boost::ut framework. We've chosen this framework because it is simple, macro-free, intuitive, and easy to use.
In this section, we will go over the basics of the framework, but you can find more information in the [Boost::ut documentation](https://boost-ext.github.io/ut/).
There are many ways to write tests, and we encourage you to read the documentation to find the way that works best for you.

#### Suites

Tests needs to be encapsulated by suites, which are defined using `suite<>` structure.

```cpp
suite<"foo"> test_foo = [] {
    // Tests go here
};
```

This puts all tests within test_foo under the suite "foo".
You can use declare multiple suites with the same name, and they will be merged together.
This allows you to declare suites in different files, and they will be merged together, keeping test files clean.

Avoid creating tests directly in the main function, as this will put them in the `global` suite, which is not recommended.

#### Tests

Tests can be defined using the `test()` lambda or the `_test` operator:

```cpp
suite<"foo"> test_foo = [] {
    "test 1"_test = [] {
        // Test 1
    };

    test("test 2") = [] {
        // Test 2
    };
};
```

#### Assertions

Both are equivalent, the received argument is the description of the test.
The description is used to identify the test in the output, and should be unique within a suite.

Assertions are done using the `expect()` function:

```cpp
suite<"foo"> test_foo = [] {
    "test 1"_test = [] {
        expect(eq(1_i, 1_i));
    };
};
```

It's always preferable to use comparison operators (eq, neq, etc.), as they provide better error messages.

#### Testing against injected dependencies

Testing against injected dependencies is done using the `di::extension::injector<>` class.
This class is used to create the dependency injection container, and can be used to set up the container for testing.
For example, to test the `RSA` class, we need to inject a `Logger` class, otherwise it will use the default SpdLog implementation.

```cpp
suite<"security"> rsaTest = [] {
	test("RSA::start logs error for missing .pem file") = [] {
		di::extension::injector<> injector{};
		DI::setTestContainer(&InMemoryLogger::install(injector));

		DI::create<RSA &>().start();

		auto &logger = dynamic_cast<InMemoryLogger &>(injector.create<Logger &>());

        expect(eq(1, logger.logs.size()) >> fatal);
		expect(
			eq(std::string{"error"}, logger.logs[0].level) and
			eq(std::string{"File key.pem not found or have problem on loading... Setting standard rsa key\n"}, logger.logs[0].message)
        );
	};
};
```
