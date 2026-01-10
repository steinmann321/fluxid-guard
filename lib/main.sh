#!/opt/homebrew/bin/bash
# Main execution logic and argument parsing

usage() {
    /bin/echo "Usage: $0 <target-directory> [OPTIONS]"
    /bin/echo ""
    /bin/echo "Options:"
    /bin/echo "  --preset <name>              Use a predefined preset (e.g., django-react-playwright)"
    /bin/echo "  --components <comp1,comp2>   Manually specify components (e.g., backend/django,frontend/react)"
    /bin/echo "  --list-presets               List available presets"
    /bin/echo "  --list-components            List available components"
    /bin/echo "  --help                       Show this help message"
    /bin/echo ""
    /bin/echo "Examples:"
    /bin/echo "  $0 /path/to/project                                    # Auto-detect"
    /bin/echo "  $0 /path/to/project --preset django-react-playwright  # Use preset"
    /bin/echo "  $0 /path/to/project --components backend/go,shared    # Manual selection"
}

parse_arguments() {
    # Check for info commands first (don't require target directory)
    if [[ $# -eq 1 ]]; then
        case $1 in
            --list-presets)
                /bin/echo "Available presets:"
                /bin/ls -1 "$PRESETS_DIR"/*.json 2>/dev/null | /usr/bin/xargs -n1 /usr/bin/basename | /usr/bin/sed 's/.json$//' | /usr/bin/sed 's/^/  /'
                exit 0
                ;;
            --list-components)
                /bin/echo "Available components:"
                list_available_components | /usr/bin/sed 's/^/  /'
                exit 0
                ;;
            --help)
                usage
                exit 0
                ;;
        esac
    fi

    # First argument must be target directory
    if [[ $# -eq 0 ]]; then
        usage
        exit 1
    fi

    TARGET_DIR="$1"
    shift

    MODE="auto"
    PRESET=""
    MANUAL_COMPONENTS=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            --preset)
                MODE="preset"
                PRESET="$2"
                shift 2
                ;;
            --components)
                MODE="manual"
                MANUAL_COMPONENTS="$2"
                shift 2
                ;;
            --help)
                usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
}

determine_components() {
    case "$MODE" in
        preset)
            log_info "Mode: Preset ($PRESET)"
            mapfile -t SELECTED_COMPONENTS < <(load_preset "$PRESET")
            ;;
        manual)
            log_info "Mode: Manual selection"
            IFS=',' read -ra SELECTED_COMPONENTS <<< "$MANUAL_COMPONENTS"
            ;;
        auto)
            log_info "Mode: Auto-detection"
            mapfile -t SELECTED_COMPONENTS < <(auto_detect_components)
            ;;
    esac

    printf "\nSelected components:\n" >&2
    printf '  - %s\n' "${SELECTED_COMPONENTS[@]}" >&2
    printf "\n" >&2
}

confirm_installation() {
    read -p "Proceed with installation? (y/n): " -n 1 -r
    printf "\n" >&2
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_warning "Installation cancelled by user"
        exit 0
    fi
}

run_installation() {

    # Uninstall existing
    uninstall_existing_hooks

    # Install each component
    for component in "${SELECTED_COMPONENTS[@]}"; do
        install_component "$component"
    done

    # Install pre-commit framework
    install_precommit_framework

    # Validate installation
    validate_installation "${SELECTED_COMPONENTS[@]}"
}

main() {
    # Parse arguments
    parse_arguments "$@"

    # Validate prerequisites (including directory existence)
    check_prerequisites

    # Convert to absolute path
    TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

    # Print header
    print_header
    log_info "Target directory: $TARGET_DIR"

    # Determine /usr/bin/which components to install
    determine_components

    # Validate dependencies
    validate_component_dependencies "${SELECTED_COMPONENTS[@]}"

    # Configure variables
    configure_variables "${SELECTED_COMPONENTS[@]}"

    # Confirm with user
    confirm_installation

    # Run installation
    run_installation

    # Print success message
    print_success_footer "${SELECTED_COMPONENTS[@]}"
}
