#!/usr/bin/env bats
# bats test_tags=unit
# Unit tests for lib/validation.sh

load '../test_helper'

setup() {
    common_setup
    source "$SCRIPT_DIR/lib/logging.sh"
    source "$SCRIPT_DIR/lib/component.sh"
    source "$SCRIPT_DIR/lib/validation.sh"
}

teardown() {
    teardown_test_dir
}

@test "check_prerequisites succeeds when jq is available" {
    run check_prerequisites
    [ "$status" -eq 0 ]
}

@test "check_prerequisites fails when target directory doesn't exist" {
    TARGET_DIR="/nonexistent/directory"

    run check_prerequisites
    [ "$status" -ne 0 ]
    assert_output_contains "Target directory does not exist"
}

@test "validate_component_dependencies succeeds for shared component" {
    mock_command "git" "" 0

    run validate_component_dependencies "shared"
    [ "$status" -eq 0 ]
}

@test "validate_component_dependencies fails when system dependency missing" {
    # Create a component with missing dependency
    local components=("backend/django")

    # Make python3 unavailable
    export PATH="/nonexistent"

    run validate_component_dependencies "${components[@]}"
    [ "$status" -ne 0 ]
    assert_output_contains "Missing system dependency"
}

@test "validate_installation succeeds when hooks directory exists" {
    /bin/mkdir -p "$TEST_DIR/.hooks"
    /usr/bin/touch "$TEST_DIR/.hooks/test.sh"
    /usr/bin/touch "$TEST_DIR/.pre-commit-config.yaml"

    run validate_installation "shared"
    [ "$status" -eq 0 ]
}

@test "validate_installation fails when hooks directory missing" {
    /usr/bin/touch "$TEST_DIR/.pre-commit-config.yaml"

    run validate_installation "shared"
    [ "$status" -ne 0 ]
    assert_output_contains "No hooks directory found"
}

@test "validate_installation fails when pre-commit config missing" {
    /bin/mkdir -p "$TEST_DIR/.hooks"
    /usr/bin/touch "$TEST_DIR/.hooks/test.sh"

    run validate_installation "shared"
    [ "$status" -ne 0 ]
    assert_output_contains "Pre-commit config missing"
}

@test "validate_installation counts hook scripts correctly" {
    /bin/mkdir -p "$TEST_DIR/.hooks"
    /usr/bin/touch "$TEST_DIR/.hooks/hook1.sh"
    /usr/bin/touch "$TEST_DIR/.hooks/hook2.sh"
    /usr/bin/touch "$TEST_DIR/.hooks/hook3.sh"
    /usr/bin/touch "$TEST_DIR/.pre-commit-config.yaml"

    run validate_installation "shared"
    [ "$status" -eq 0 ]
    assert_output_contains "3 hook scripts installed"
}
