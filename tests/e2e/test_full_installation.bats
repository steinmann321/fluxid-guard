#!/usr/bin/env bats
# bats test_tags=unit
# E2E tests for full installation workflow

load '../test_helper'

setup() {
    common_setup

    # Mock all external tools
    mock_python_venv
    mock_pip
    mock_npm
    mock_npx
    mock_go
    mock_precommit
}

teardown() {
    teardown_test_dir
}

@test "install.sh with auto-detection detects Django project" {
    create_mock_django_project

    run "$SCRIPT_DIR/install.sh" "$TEST_DIR" <<< "y"

    [ "$status" -eq 0 ]
    assert_output_contains "backend/django"
    assert_output_contains "shared"
}

@test "install.sh with auto-detection creates hooks directory" {
    create_mock_django_project

    "$SCRIPT_DIR/install.sh" "$TEST_DIR" <<< "y"

    assert_dir_exists "$TEST_DIR/.hooks"
}

@test "install.sh with auto-detection installs shared hooks" {
    create_mock_django_project

    "$SCRIPT_DIR/install.sh" "$TEST_DIR" <<< "y"

    assert_file_exists "$TEST_DIR/.hooks/shared-guard.sh"
    assert_file_exists "$TEST_DIR/.hooks/check-bypass-directives.sh"
}

@test "install.sh with django-only preset works" {
    create_mock_django_project

    run "$SCRIPT_DIR/install.sh" "$TEST_DIR" --preset django-only <<< "y"

    [ "$status" -eq 0 ]
    assert_output_contains "Loading preset: django-only"
    assert_output_contains "shared"
    assert_output_contains "backend/django"
}

@test "install.sh with preset installs correct components" {
    create_mock_django_project

    "$SCRIPT_DIR/install.sh" "$TEST_DIR" --preset django-only <<< "y"

    assert_file_exists "$TEST_DIR/.hooks/shared-guard.sh"
    assert_file_exists "$TEST_DIR/.hooks/backend-guard.sh"
    assert_file_exists "$TEST_DIR/.hooks/backend-max-lines.sh"
}

@test "install.sh with manual components works" {
    create_mock_django_project

    run "$SCRIPT_DIR/install.sh" "$TEST_DIR" --components shared,backend/django <<< "y"

    [ "$status" -eq 0 ]
    assert_output_contains "Mode: Manual selection"
    assert_output_contains "shared"
    assert_output_contains "backend/django"
}

@test "install.sh --list-presets shows available presets" {
    run "$SCRIPT_DIR/install.sh" --list-presets

    [ "$status" -eq 0 ]
    assert_output_contains "django-only"
    assert_output_contains "django-react-playwright"
    assert_output_contains "go-only"
}

@test "install.sh --list-components shows available components" {
    run "$SCRIPT_DIR/install.sh" --list-components

    [ "$status" -eq 0 ]
    assert_output_contains "backend/django"
    assert_output_contains "backend/go"
    assert_output_contains "frontend/react"
    assert_output_contains "e2e/playwright"
    assert_output_contains "shared"
}

@test "install.sh --help shows usage information" {
    run "$SCRIPT_DIR/install.sh" --help

    [ "$status" -eq 0 ]
    assert_output_contains "Usage:"
    assert_output_contains "--preset"
    assert_output_contains "--components"
}

@test "install.sh with invalid preset fails gracefully" {
    create_mock_django_project

    run "$SCRIPT_DIR/install.sh" "$TEST_DIR" --preset nonexistent

    [ "$status" -ne 0 ]
    assert_output_contains "Preset not found"
}

@test "install.sh without arguments shows usage" {
    run "$SCRIPT_DIR/install.sh"

    [ "$status" -eq 1 ]
    assert_output_contains "Usage:"
}

@test "install.sh with nonexistent directory fails" {
    run "$SCRIPT_DIR/install.sh" "/nonexistent/directory" <<< "y"

    [ "$status" -ne 0 ]
    assert_output_contains "Target directory does not exist"
}

@test "installed hooks are executable and read-only" {
    create_mock_django_project

    "$SCRIPT_DIR/install.sh" "$TEST_DIR" --preset django-only <<< "y"

    for hook in "$TEST_DIR/.hooks"/*.sh; do
        [ -x "$hook" ]
        assert_file_permissions "$hook" "555"
    done
}

@test "installed config files are present" {
    create_mock_django_project

    "$SCRIPT_DIR/install.sh" "$TEST_DIR" --preset django-only <<< "y"

    assert_file_exists "$TEST_DIR/.pre-commit-config.yaml"
    assert_file_exists "$TEST_DIR/.gitleaks.toml"
    assert_file_exists "$TEST_DIR/.jscpdrc"
    assert_dir_exists "$TEST_DIR/.semgrep"
}

@test "installation shows success message" {
    create_mock_django_project

    run "$SCRIPT_DIR/install.sh" "$TEST_DIR" --preset django-only <<< "y"

    [ "$status" -eq 0 ]
    assert_output_contains "Enterprise-Grade QA Enforcement Activated"
}

@test "user can cancel installation" {
    create_mock_django_project

    run "$SCRIPT_DIR/install.sh" "$TEST_DIR" --preset django-only <<< "n"

    [ "$status" -eq 0 ]
    assert_output_contains "Installation cancelled by user"
    [ ! -d "$TEST_DIR/.hooks" ]
}

@test "full stack installation with django-react-playwright" {
    create_mock_django_project
    create_mock_react_project
    create_mock_playwright_project

    run "$SCRIPT_DIR/install.sh" "$TEST_DIR" --preset django-react-playwright <<< "y"

    [ "$status" -eq 0 ]
    assert_output_contains "shared"
    assert_output_contains "backend/django"
    assert_output_contains "frontend/react"
    assert_output_contains "e2e/playwright"
}

@test "go-only preset installs Go components" {
    create_mock_go_project

    run "$SCRIPT_DIR/install.sh" "$TEST_DIR" --preset go-only <<< "y"

    [ "$status" -eq 0 ]
    assert_output_contains "shared"
    assert_output_contains "backend/go"
}

@test "auto-detection works for mixed Django + React project" {
    create_mock_django_project
    create_mock_react_project

    run "$SCRIPT_DIR/install.sh" "$TEST_DIR" <<< "y"

    [ "$status" -eq 0 ]
    assert_output_contains "Detected backend/django"
    assert_output_contains "Detected frontend/react"
}

@test "reinstallation removes old hooks first" {
    create_mock_django_project

    # First installation
    "$SCRIPT_DIR/install.sh" "$TEST_DIR" --preset django-only <<< "y"
    assert_file_exists "$TEST_DIR/.hooks/shared-guard.sh"

    # Create a dummy file that shouldn't persist
    /usr/bin/touch "$TEST_DIR/.hooks/dummy.sh"

    # Reinstall
    "$SCRIPT_DIR/install.sh" "$TEST_DIR" --preset django-only <<< "y"

    # Dummy file should be gone
    [ ! -f "$TEST_DIR/.hooks/dummy.sh" ]

    # Real hooks should still be there
    assert_file_exists "$TEST_DIR/.hooks/shared-guard.sh"
}
