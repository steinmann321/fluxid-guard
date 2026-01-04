#!/usr/bin/env bats
# bats test_tags=unit
# Unit tests for lib/component.sh

load '../test_helper'

setup() {
    common_setup
    source "$SCRIPT_DIR/lib/logging.sh"
    source "$SCRIPT_DIR/lib/component.sh"
    declare -A CONFIG_VARS
    export CONFIG_VARS
}

teardown() {
    teardown_test_dir
}

@test "list_available_components finds Django component" {
    run list_available_components
    [ "$status" -eq 0 ]
    assert_output_contains "backend/django"
}

@test "list_available_components finds Go component" {
    run list_available_components
    [ "$status" -eq 0 ]
    assert_output_contains "backend/go"
}

@test "list_available_components finds React component" {
    run list_available_components
    [ "$status" -eq 0 ]
    assert_output_contains "frontend/react"
}

@test "list_available_components finds Playwright component" {
    run list_available_components
    [ "$status" -eq 0 ]
    assert_output_contains "e2e/playwright"
}

@test "list_available_components finds shared component" {
    run list_available_components
    [ "$status" -eq 0 ]
    assert_output_contains "shared"
}

@test "load_component_metadata returns valid JSON for shared" {
    run load_component_metadata "shared"
    [ "$status" -eq 0 ]

    # Verify it's valid JSON by parsing with jq
    echo "$output" | jq . > /dev/null
    [ $? -eq 0 ]
}

@test "load_component_metadata returns valid JSON for Django" {
    run load_component_metadata "backend/django"
    [ "$status" -eq 0 ]

    echo "$output" | jq . > /dev/null
    [ $? -eq 0 ]
}

@test "load_component_metadata fails for non-existent component" {
    run load_component_metadata "backend/nonexistent"
    [ "$status" -ne 0 ]
    assert_output_contains "Component metadata not found"
}

@test "detect_component detects Django project" {
    create_mock_django_project

    run detect_component "backend/django"
    [ "$status" -eq 0 ]
}

@test "detect_component detects Go project" {
    create_mock_go_project

    run detect_component "backend/go"
    [ "$status" -eq 0 ]
}

@test "detect_component fails for Django in non-Django project" {
    /bin/mkdir -p "$TEST_DIR"
    (cd "$TEST_DIR" && git init -q)

    run detect_component "backend/django"
    [ "$status" -ne 0 ]
}

@test "auto_detect_components always includes shared" {
    create_mock_django_project

    run auto_detect_components
    [ "$status" -eq 0 ]
    assert_output_contains "shared"
}

@test "auto_detect_components detects Django" {
    create_mock_django_project

    run auto_detect_components
    [ "$status" -eq 0 ]
    assert_output_contains "backend/django"
}

@test "auto_detect_components detects multiple components" {
    create_mock_django_project
    create_mock_react_project

    run auto_detect_components
    [ "$status" -eq 0 ]
    assert_output_contains "shared"
    assert_output_contains "backend/django"
    assert_output_contains "frontend/react"
}

@test "load_preset loads django-only preset" {
    run load_preset "django-only"
    [ "$status" -eq 0 ]
    assert_output_contains "shared"
    assert_output_contains "backend/django"
}

@test "load_preset loads django-react-playwright preset" {
    run load_preset "django-react-playwright"
    [ "$status" -eq 0 ]
    assert_output_contains "shared"
    assert_output_contains "backend/django"
    assert_output_contains "frontend/react"
    assert_output_contains "e2e/playwright"
}

@test "load_preset sets CONFIG_VARS from preset" {
    load_preset "django-only" > /dev/null

    [ "${CONFIG_VARS[backend_port]}" = "8000" ]
}

@test "load_preset fails for non-existent preset" {
    run load_preset "nonexistent"
    [ "$status" -ne 0 ]
    assert_output_contains "Preset not found"
}
