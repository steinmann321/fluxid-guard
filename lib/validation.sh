#!/opt/homebrew/bin/bash
# Validation functions for dependencies and installation

validate_component_dependencies() {
    local components=("$@")

    log_info "Validating component dependencies..."

    for component in "${components[@]}"; do
        local metadata=$(load_component_metadata "$component")

        # Check system dependencies
        local sys_deps=$(echo "$metadata" | /opt/homebrew/bin/jq -r '.dependencies.system[]? // empty')
        for dep in $sys_deps; do
            # Check with absolute paths for common commands
            local dep_found=false
            case "$dep" in
                git) [[ -x "/usr/bin/git" ]] && dep_found=true ;;
                python3) [[ -x "/usr/bin/python3" || -x "/opt/homebrew/bin/python3" ]] && dep_found=true ;;
                node) [[ -x "/usr/local/bin/node" || -x "/opt/homebrew/bin/node" ]] && dep_found=true ;;
                go) [[ -x "/usr/local/go/bin/go" || -x "/opt/homebrew/bin/go" ]] && dep_found=true ;;
                *) /usr/bin/which "$dep" &> /dev/null && dep_found=true ;;
            esac

            if ! $dep_found; then
                log_error "Missing system dependency for $component: $dep"
                exit 1
            fi
        done

        # Check component dependencies
        local comp_deps=$(echo "$metadata" | /opt/homebrew/bin/jq -r '.dependencies.components[]? // empty')
        for dep in $comp_deps; do
            if [[ ! " ${components[@]} " =~ " ${dep} " ]]; then
                log_warning "Component $component requires: $dep (adding automatically)"
                components+=("$dep")
            fi
        done
    done

    log_success "All dependencies validated"
}

validate_installation() {
    local components=("$@")

    log_info "Validating installation..."

    cd "$TARGET_DIR"

    local all_good=true

    # Check hook directory exists
    if [[ -d ".hooks" ]]; then
        local hook_count=$(/usr/bin/find .hooks -name "*.sh" | /usr/bin/wc -l | /usr/bin/tr -d '[:space:]')
        log_success "$hook_count hook scripts installed"
    else
        log_error "No hooks directory found"
        all_good=false
    fi

    # Check for pre-commit config
    if [[ -f ".pre-commit-config.yaml" ]]; then
        log_success "Pre-commit config present"
    else
        log_error "Pre-commit config missing"
        all_good=false
    fi

    if $all_good; then
        log_success "Installation validation passed"
    else
        log_error "Installation validation failed"
        return 1
    fi
}

check_prerequisites() {
    # Check for jq
    if ! command -v /opt/homebrew/bin/jq &> /dev/null; then
        log_error "jq is required but not installed. Please install jq."
        exit 1
    fi

    # Check target directory exists
    if [[ ! -d "$TARGET_DIR" ]]; then
        log_error "Target directory does not exist: $TARGET_DIR"
        exit 1
    fi
}
