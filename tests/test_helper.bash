#!/opt/homebrew/bin/bash
# Test helper utilities for fluxid QA test suite

# Load bats support libraries
load_bats_support() {
    # Try to load bats-support and bats-assert if available
    if [[ -f "/usr/local/lib/bats-support/load.bash" ]]; then
        load "/usr/local/lib/bats-support/load.bash"
        load "/usr/local/lib/bats-assert/load.bash"
    fi
}

# Create temporary test directory
setup_test_dir() {
    TEST_DIR="$(mktemp -d -t fluxid-test.XXXXXX)"
    export TEST_DIR
    export ORIGINAL_DIR="$(pwd)"
}

# Cleanup after test
teardown_test_dir() {
    if [[ -n "${TEST_DIR:-}" && -d "$TEST_DIR" ]]; then
        /bin/chmod -R u+w "$TEST_DIR" 2>/dev/null || true
        /bin/rm -rf "$TEST_DIR"
    fi
}

# Create a mock Django project structure
create_mock_django_project() {
    /bin/mkdir -p "$TEST_DIR/backend"

    /bin/echo "django==4.2" > "$TEST_DIR/backend/requirements.txt"

    /bin/cat > "$TEST_DIR/backend/manage.py" <<'EOF'
#!/usr/bin/env python
import sys
if __name__ == "__main__":
    sys.exit(0)
EOF
    /bin/chmod +x "$TEST_DIR/backend/manage.py"

    # Initialize git
    (cd "$TEST_DIR" && /usr/bin/git init -q && /usr/bin/git config user.email "test@test.com" && /usr/bin/git config user.name "Test User")
}

# Create a mock Go project structure
create_mock_go_project() {
    /bin/cat > "$TEST_DIR/go.mod" <<'EOF'
module example.com/myapp

go 1.21
EOF

    /bin/mkdir -p "$TEST_DIR/cmd/server"
    /bin/cat > "$TEST_DIR/cmd/server/main.go" <<'EOF'
package main

func main() {}
EOF

    # Initialize git
    (cd "$TEST_DIR" && /usr/bin/git init -q && /usr/bin/git config user.email "test@test.com" && /usr/bin/git config user.name "Test User")
}

# Create a mock React project structure
create_mock_react_project() {
    /bin/mkdir -p "$TEST_DIR/frontend/src"

    /bin/cat > "$TEST_DIR/frontend/package.json" <<'EOF'
{
  "name": "frontend",
  "version": "1.0.0",
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  }
}
EOF

    # Initialize /usr/bin/git if not already initialized
    if [[ ! -d "$TEST_DIR/.git" ]]; then
        (cd "$TEST_DIR" && /usr/bin/git init -q && /usr/bin/git config user.email "test@test.com" && /usr/bin/git config user.name "Test User")
    fi
}

# Create a mock Playwright project structure
create_mock_playwright_project() {
    /bin/mkdir -p "$TEST_DIR/e2e-tests/tests"

    /bin/cat > "$TEST_DIR/e2e-tests/package.json" <<'EOF'
{
  "name": "e2e-tests",
  "version": "1.0.0",
  "devDependencies": {
    "@playwright/test": "^1.40.0"
  }
}
EOF

    # Initialize /usr/bin/git if not already initialized
    if [[ ! -d "$TEST_DIR/.git" ]]; then
        (cd "$TEST_DIR" && /usr/bin/git init -q && /usr/bin/git config user.email "test@test.com" && /usr/bin/git config user.name "Test User")
    fi
}

# Mock external commands
mock_command() {
    local cmd=$1
    local output=${2:-""}
    local exit_code=${3:-0}

    /bin/mkdir -p "$TEST_DIR/bin"
    /bin/cat > "$TEST_DIR/bin/$cmd" <<EOF
#!/opt/homebrew/bin/bash
/bin/echo "$output"
exit $exit_code
EOF
    /bin/chmod +x "$TEST_DIR/bin/$cmd"
    export PATH="$TEST_DIR/bin:\$PATH"
}

# Mock Python command that creates venv
mock_python_venv() {
    /bin/mkdir -p "$TEST_DIR/bin"
    /bin/cat > "$TEST_DIR/bin/python3" <<'EOF'
#!/opt/homebrew/bin/bash
if [[ "$1" == "-m" && "$2" == "venv" ]]; then
    /bin/mkdir -p "$3/bin"
    /usr/bin/touch "$3/bin/pip"
    /bin/chmod +x "$3/bin/pip"
    exit 0
fi
/bin/echo "Python 3.11.0"
exit 0
EOF
    /bin/chmod +x "$TEST_DIR/bin/python3"
    export PATH="$TEST_DIR/bin:\$PATH"
}

# Mock pip command
mock_pip() {
    /bin/mkdir -p "$TEST_DIR/bin"
    /bin/cat > "$TEST_DIR/bin/pip" <<'EOF'
#!/opt/homebrew/bin/bash
exit 0
EOF
    /bin/chmod +x "$TEST_DIR/bin/pip"
    export PATH="$TEST_DIR/bin:\$PATH"
}

# Mock npm command
mock_npm() {
    /bin/mkdir -p "$TEST_DIR/bin"
    /bin/cat > "$TEST_DIR/bin/npm" <<'EOF'
#!/opt/homebrew/bin/bash
if [[ "$1" == "install" ]]; then
    /bin/mkdir -p node_modules
    exit 0
fi
/bin/echo "8.0.0"
exit 0
EOF
    /bin/chmod +x "$TEST_DIR/bin/npm"
    export PATH="$TEST_DIR/bin:\$PATH"
}

# Mock npx command
mock_npx() {
    /bin/mkdir -p "$TEST_DIR/bin"
    /bin/cat > "$TEST_DIR/bin/npx" <<'EOF'
#!/opt/homebrew/bin/bash
exit 0
EOF
    /bin/chmod +x "$TEST_DIR/bin/npx"
    export PATH="$TEST_DIR/bin:\$PATH"
}

# Mock go command
mock_go() {
    /bin/mkdir -p "$TEST_DIR/bin"
    /bin/cat > "$TEST_DIR/bin/go" <<'EOF'
#!/opt/homebrew/bin/bash
exit 0
EOF
    /bin/chmod +x "$TEST_DIR/bin/go"
    export PATH="$TEST_DIR/bin:\$PATH"
}

# Mock pre-commit command
mock_precommit() {
    /bin/mkdir -p "$TEST_DIR/bin"
    /bin/cat > "$TEST_DIR/bin/pre-commit" <<'EOF'
#!/opt/homebrew/bin/bash
exit 0
EOF
    /bin/chmod +x "$TEST_DIR/bin/pre-commit"
    export PATH="$TEST_DIR/bin:\$PATH"
}

# Assert file exists
assert_file_exists() {
    local file=$1
    [[ -f "$file" ]] || {
        /bin/echo "File does not exist: $file"
        return 1
    }
}

# Assert directory exists
assert_dir_exists() {
    local dir=$1
    [[ -d "$dir" ]] || {
        /bin/echo "Directory does not exist: $dir"
        return 1
    }
}

# Assert file has specific permissions
assert_file_permissions() {
    local file=$1
    local expected_perms=$2

    local actual_perms
    if [[ "$OSTYPE" == "darwin"* ]]; then
        actual_perms=$(/usr/bin/stat -f "%Lp" "$file")
    else
        actual_perms=$(/usr/bin/stat -c "%a" "$file")
    fi

    [[ "$actual_perms" == "$expected_perms" ]] || {
        /bin/echo "Expected permissions $expected_perms but got $actual_perms for $file"
        return 1
    }
}

# Assert file contains pattern
assert_file_contains() {
    local file=$1
    local pattern=$2

    /usr/bin/grep -q -- "$pattern" "$file" || {
        /bin/echo "File $file does not contain pattern: $pattern"
        return 1
    }
}

# Assert output contains string
assert_output_contains() {
    local expected=$1
    /bin/echo "$output" | /usr/bin/grep -q -- "$expected" || {
        /bin/echo "Output does not contain: $expected"
        /bin/echo "Actual output: $output"
        return 1
    }
}

# Setup common test environment
common_setup() {
    setup_test_dir

    export SCRIPT_DIR="$ORIGINAL_DIR"
    export COMPONENTS_DIR="$SCRIPT_DIR/components"
    export PRESETS_DIR="$SCRIPT_DIR/presets"
    export TARGET_DIR="$TEST_DIR"

    # Mock jq to use real jq
    export PATH="/usr/bin:/bin:/usr/local/bin:$PATH"
}
