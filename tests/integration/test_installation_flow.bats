#!/usr/bin/env bats
# bats test_tags=unit
# Integration tests for installation flow

load '../test_helper'

setup() {
    common_setup
    declare -A CONFIG_VARS
    export CONFIG_VARS

    source "$SCRIPT_DIR/lib/logging.sh"
    source "$SCRIPT_DIR/lib/component.sh"
    source "$SCRIPT_DIR/lib/validation.sh"
    source "$SCRIPT_DIR/lib/config.sh"
    source "$SCRIPT_DIR/lib/install.sh"

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

@test "uninstall_existing_hooks removes .hooks directory" {
    create_mock_django_project

    /bin/mkdir -p "$TEST_DIR/.hooks"
    /usr/bin/touch "$TEST_DIR/.hooks/test.sh"

    run uninstall_existing_hooks
    [ "$status" -eq 0 ]
    [ ! -d "$TEST_DIR/.hooks" ]
}

@test "uninstall_existing_hooks removes read-only hooks" {
    create_mock_django_project

    /bin/mkdir -p "$TEST_DIR/.hooks"
    /usr/bin/touch "$TEST_DIR/.hooks/test.sh"
    /bin/chmod 555 "$TEST_DIR/.hooks/test.sh"

    run uninstall_existing_hooks
    [ "$status" -eq 0 ]
    [ ! -d "$TEST_DIR/.hooks" ]
}

@test "uninstall_existing_hooks removes config files" {
    create_mock_django_project

    /usr/bin/touch "$TEST_DIR/.pre-commit-config.yaml"
    /usr/bin/touch "$TEST_DIR/.gitleaks.toml"
    /bin/mkdir -p "$TEST_DIR/.semgrep"

    run uninstall_existing_hooks
    [ "$status" -eq 0 ]
    [ ! -f "$TEST_DIR/.pre-commit-config.yaml" ]
    [ ! -f "$TEST_DIR/.gitleaks.toml" ]
    [ ! -d "$TEST_DIR/.semgrep" ]
}

@test "install_component creates .hooks directory" {
    create_mock_django_project

    run install_component "shared"
    [ "$status" -eq 0 ]
    assert_dir_exists "$TEST_DIR/.hooks"
}

@test "install_component copies hook scripts" {
    create_mock_django_project

    install_component "shared"

    assert_file_exists "$TEST_DIR/.hooks/shared-guard.sh"
    assert_file_exists "$TEST_DIR/.hooks/check-bypass-directives.sh"
}

@test "install_component makes hooks read-only (555)" {
    create_mock_django_project

    install_component "shared"

    for hook in "$TEST_DIR/.hooks"/*.sh; do
        assert_file_permissions "$hook" "555"
    done
}

@test "install_component copies config files for shared" {
    create_mock_django_project

    install_component "shared"

    assert_file_exists "$TEST_DIR/.gitleaks.toml"
    assert_file_exists "$TEST_DIR/.jscpdrc"
    assert_file_exists "$TEST_DIR/.pre-commit-config.yaml"
    assert_dir_exists "$TEST_DIR/.semgrep"
    assert_file_exists "$TEST_DIR/.semgrep/base.yml"
    assert_file_exists "$TEST_DIR/.semgrep/e2e.yml"
}

@test "install_component installs Django backend component" {
    create_mock_django_project

    run install_component "backend/django"
    [ "$status" -eq 0 ]
    assert_output_contains "Django"
}

@test "install_django creates venv" {
    create_mock_django_project

    cd "$TEST_DIR/backend"
    install_django

    assert_dir_exists "$TEST_DIR/backend/.venv"
}

@test "install_component copies Django hooks" {
    create_mock_django_project

    install_component "backend/django"

    assert_file_exists "$TEST_DIR/.hooks/backend-guard.sh"
    assert_file_exists "$TEST_DIR/.hooks/backend-max-lines.sh"
}

@test "install_component handles React frontend" {
    create_mock_react_project

    run install_component "frontend/react"
    [ "$status" -eq 0 ]
}

@test "install_component copies React configs" {
    create_mock_react_project

    install_component "frontend/react"

    assert_file_exists "$TEST_DIR/frontend/eslint.config.js"
    assert_file_exists "$TEST_DIR/frontend/vite.config.ts"
    assert_file_exists "$TEST_DIR/frontend/tsconfig.json"
}

@test "install_component substitutes template variables" {
    create_mock_react_project
    CONFIG_VARS[backend_port]=9000

    install_component "frontend/react"

    assert_file_contains "$TEST_DIR/frontend/vite.config.ts" "9000"
}

@test "install_precommit_framework installs hooks" {
    create_mock_django_project

    run install_precommit_framework
    [ "$status" -eq 0 ]
}

@test "multiple components can be installed sequentially" {
    create_mock_django_project
    create_mock_react_project

    install_component "shared"
    install_component "backend/django"
    install_component "frontend/react"

    # Verify all hooks exist
    assert_file_exists "$TEST_DIR/.hooks/shared-guard.sh"
    assert_file_exists "$TEST_DIR/.hooks/backend-guard.sh"
    assert_file_exists "$TEST_DIR/.hooks/frontend-guard.sh"
}

@test "reinstall removes old hooks before installing new ones" {
    create_mock_django_project

    # First installation
    install_component "shared"
    assert_file_exists "$TEST_DIR/.hooks/shared-guard.sh"

    # Uninstall
    uninstall_existing_hooks
    [ ! -d "$TEST_DIR/.hooks" ]

    # Reinstall
    install_component "shared"
    assert_file_exists "$TEST_DIR/.hooks/shared-guard.sh"
}
