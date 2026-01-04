#!/usr/bin/env bats
# bats test_tags=unit
# Unit tests for lib/logging.sh

load '../test_helper'

setup() {
    source "$BATS_TEST_DIRNAME/../../lib/logging.sh"
}

@test "log_info outputs info message with icon" {
    run log_info "test message"
    [ "$status" -eq 0 ]
    assert_output_contains "ℹ"
    assert_output_contains "test message"
}

@test "log_success outputs success message with icon" {
    run log_success "success message"
    [ "$status" -eq 0 ]
    assert_output_contains "✓"
    assert_output_contains "success message"
}

@test "log_warning outputs warning message with icon" {
    run log_warning "warning message"
    [ "$status" -eq 0 ]
    assert_output_contains "⚠"
    assert_output_contains "warning message"
}

@test "log_error outputs error message with icon" {
    run log_error "error message"
    [ "$status" -eq 0 ]
    assert_output_contains "✗"
    assert_output_contains "error message"
}

@test "print_header outputs fluxid header" {
    run print_header
    [ "$status" -eq 0 ]
    assert_output_contains "fluxid"
    assert_output_contains "Modular Component System"
}

@test "print_success_footer outputs installed components" {
    run print_success_footer "shared" "backend/django"
    [ "$status" -eq 0 ]
    assert_output_contains "Enterprise-Grade QA Enforcement Activated"
    assert_output_contains "shared"
    assert_output_contains "backend/django"
}
