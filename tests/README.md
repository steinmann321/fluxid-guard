# fluxid QA Test Suite

Comprehensive test suite for the fluxid QA modular component system.

## Test Structure

```
tests/
├── unit/                        # Fast, isolated function tests
│   ├── test_logging.bats       # Tests for lib/logging.sh
│   ├── test_component.bats     # Tests for lib/component.sh
│   └── test_validation.bats    # Tests for lib/validation.sh
├── integration/                 # Module interaction tests
│   └── test_installation_flow.bats
├── e2e/                        # Full installation tests
│   └── test_full_installation.bats
├── test_helper.bash            # Common test utilities
├── run_tests.sh                # Test runner script
└── README.md                   # This file
```

## Prerequisites

Install testing dependencies:

**macOS:**
```bash
brew install bats-core jq
```

**Ubuntu/Debian:**
```bash
sudo apt-get install bats jq
```

**npm (any platform):**
```bash
npm install -g bats
```

## Running Tests

### Run all tests
```bash
./tests/run_tests.sh
```

### Run specific test suites
```bash
# Unit tests only
bats tests/unit/

# Integration tests only
bats tests/integration/

# E2E tests only
bats tests/e2e/

# Single test file
bats tests/unit/test_logging.bats
```

### Run specific test
```bash
bats tests/unit/test_logging.bats --filter "log_info"
```

## Test Coverage

### Unit Tests (Fast, ~10ms each)
- **lib/logging.sh**: Output formatting, headers, footers
- **lib/component.sh**: Component discovery, detection, preset loading
- **lib/validation.sh**: Dependency checking, installation validation

### Integration Tests (Medium, ~100ms each)
- **Installation flow**: Component installation, hook copying, config merging
- **Uninstall/reinstall**: Cleanup and idempotency
- **Multiple components**: Sequential installation

### E2E Tests (Slower, ~1s each)
- **Full installation**: Complete workflow from start to finish
- **Preset usage**: django-only, django-react-playwright, go-only
- **Auto-detection**: Automatic component discovery
- **Manual selection**: Component specification
- **Error handling**: Invalid presets, missing directories

## Test Utilities

### Mock Functions
```bash
# Mock external commands
mock_command "python3" "Python 3.11.0" 0

# Mock Python venv creation
mock_python_venv

# Mock npm/pip/go/pre-commit
mock_npm
mock_pip
mock_go
mock_precommit
```

### Project Mocking
```bash
# Create mock project structures
create_mock_django_project    # Django backend
create_mock_go_project         # Go backend
create_mock_react_project      # React frontend
create_mock_playwright_project # Playwright E2E
```

### Assertions
```bash
# File/directory checks
assert_file_exists "$file"
assert_dir_exists "$dir"
assert_file_permissions "$file" "555"
assert_file_contains "$file" "pattern"

# Output checks
assert_output_contains "expected string"
```

## Writing New Tests

### Test File Template
```bash
#!/usr/bin/env bats
# Description of test file

load '../test_helper'

setup() {
    common_setup
    source "$SCRIPT_DIR/lib/yourmodule.sh"
}

teardown() {
    teardown_test_dir
}

@test "description of what it tests" {
    # Arrange
    create_mock_django_project

    # Act
    run your_function "arg1" "arg2"

    # Assert
    [ "$status" -eq 0 ]
    assert_output_contains "expected output"
}
```

### Best Practices

1. **Use temporary directories**: All tests run in isolated temp dirs
2. **Mock external commands**: Don't depend on system installations
3. **Test both success and failure**: Cover error cases
4. **Keep tests fast**: Unit tests should be <100ms
5. **Clean up**: Use teardown to remove test directories
6. **Descriptive names**: Test names should explain what they verify
7. **One assertion per test**: Keep tests focused

## CI/CD Integration

Tests run automatically on:
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop`

See `.github/workflows/test.yml` for CI configuration.

## Debugging Tests

### Run with verbose output
```bash
bats --tap tests/unit/test_logging.bats
```

### Run single test with trace
```bash
bats --trace tests/unit/test_logging.bats --filter "log_info"
```

### Check test environment
```bash
# Verify mock setup
@test "debug test environment" {
    echo "TEST_DIR: $TEST_DIR"
    echo "SCRIPT_DIR: $SCRIPT_DIR"
    echo "PATH: $PATH"
    ls -la "$TEST_DIR"
}
```

## Test Statistics

Run `./tests/run_tests.sh` to see:
- Total tests run
- Pass/fail counts
- Execution time per suite

## Contributing

When adding new features:
1. Write tests first (TDD)
2. Ensure all tests pass
3. Add both success and failure cases
4. Update this README if adding new utilities

## Troubleshooting

**"bats: command not found"**
- Install bats using instructions above

**"jq: command not found"**
- Install jq: `brew install jq` or `apt install jq`

**Tests fail with permission errors**
- Check that hooks are being set to 555 permissions
- Verify teardown properly cleans up read-only files

**Temp directories not cleaned up**
- Check `teardown_test_dir()` is called in teardown
- Manually remove: `rm -rf /tmp/fluxid-test.*`
