#!/opt/homebrew/bin/bash
# Installation functions

uninstall_existing_hooks() {
    log_info "Removing existing hooks (if any)..."

    cd "$TARGET_DIR"

    # Remove existing hooks and configs
    # Make hook scripts writable first (they are read-only)
    [[ -d ".hooks" ]] && /bin/chmod -R u+w .hooks 2>/dev/null || true
    /bin/rm -rf .hooks
    /bin/rm -f .pre-commit-config.yaml
    /bin/rm -rf .semgrep
    /bin/rm -f .gitleaks.toml
    /bin/rm -f .jscpdrc
    /bin/rm -f .jscpdignore
    /bin/rm -f .semgrepignore

    # Uninstall pre-commit hooks
    if command -v pre-commit &> /dev/null; then
        pre-commit uninstall 2>/dev/null || true
    fi

    log_success "Cleanup complete"
}

install_component() {
    local component=$1
    local metadata=$(load_component_metadata "$component")
    local component_dir="$COMPONENTS_DIR/$component"

    log_info "Installing component: $component"

    cd "$TARGET_DIR"

    # 1. Copy hooks (make read-only)
    /bin/mkdir -p .hooks
    local hooks=$(echo "$metadata" | /opt/homebrew/bin/jq -r '.hooks[]? // empty')
    for hook in $hooks; do
        local hook_file="$component_dir/$hook"
        if [[ -f "$hook_file" ]]; then
            /bin/cp "$hook_file" .hooks/
            /bin/chmod 555 ".hooks/$(/usr/bin/basename $hook)"
        fi
    done

    # 2. Copy config files
    local config_copies=$(echo "$metadata" | /opt/homebrew/bin/jq -c '.installation.config_copies[]? // empty')
    while IFS= read -r config; do
        if [[ -n "$config" ]]; then
            local source=$(echo "$config" | /opt/homebrew/bin/jq -r '.source')
            local target=$(echo "$config" | /opt/homebrew/bin/jq -r '.target')
            local template_vars=$(echo "$config" | /opt/homebrew/bin/jq -r '.template_vars[]? // empty')

            local source_file="$component_dir/$source"
            if [[ -f "$source_file" ]]; then
                # Create parent directory if it doesn't exist
                local target_dir=$(/usr/bin/dirname "$target")
                [[ -n "$target_dir" && "$target_dir" != "." ]] && /bin/mkdir -p "$target_dir"

                /bin/cp "$source_file" "$target"

                # Replace template variables
                for var in $template_vars; do
                    if [[ -n "${CONFIG_VARS[$var]:-}" ]]; then
                        /usr/bin/sed -i.bak "s/__${var^^}__/${CONFIG_VARS[$var]}/g" "$target"
                        /bin/rm -f "${target}.bak"
                    fi
                done
            fi
        fi
    done <<< "$config_copies"

    # 3. Merge config files
    local config_merges=$(echo "$metadata" | /opt/homebrew/bin/jq -c '.installation.config_merges[]? // empty')
    while IFS= read -r config; do
        if [[ -n "$config" ]]; then
            local source=$(echo "$config" | /opt/homebrew/bin/jq -r '.source')
            local target=$(echo "$config" | /opt/homebrew/bin/jq -r '.target')
            local create_if_missing=$(echo "$config" | /opt/homebrew/bin/jq -r '.create_if_missing // false')

            local source_file="$component_dir/$source"
            if [[ -f "$source_file" ]]; then
                if [[ -f "$target" ]]; then
                    python3 "$SCRIPT_DIR/merge-config.py" "$target" "$source_file" -o "$target"
                elif [[ "$create_if_missing" == "true" ]]; then
                    /bin/cp "$source_file" "$target"
                fi
            fi
        fi
    done <<< "$config_merges"

    # 4. Component-specific installation
    local component_type=$(echo "$metadata" | /opt/homebrew/bin/jq -r '.type')

    case "$component_type" in
        backend)
            install_backend_component "$component" "$metadata" "$component_dir"
            ;;
        frontend)
            install_frontend_component "$component" "$metadata" "$component_dir"
            ;;
        e2e)
            install_e2e_component "$component" "$metadata" "$component_dir"
            ;;
        shared)
            install_shared_component "$component" "$metadata" "$component_dir"
            ;;
    esac

    log_success "Component $component installed"
}

install_backend_component() {
    local component=$1
    local metadata=$2
    local component_dir=$3

    local name=$(echo "$metadata" | /opt/homebrew/bin/jq -r '.name')

    case "$name" in
        django)
            install_django
            ;;
        go)
            install_go
            ;;
    esac
}

install_django() {
    log_info "Setting up Django/Python environment..."

    cd "$TARGET_DIR/backend"

    # Create venv
    if [[ ! -d ".venv" ]]; then
        # Use python3 from PATH (includes mocked commands in tests)
        local python_cmd=$(/usr/bin/which python3 2>/dev/null || echo "python3")
        "$python_cmd" -m venv .venv
        log_success "Python virtual environment created"
    fi

    local venv_pip=".venv/bin/pip"

    # Upgrade pip
    "$venv_pip" install --upgrade pip > /dev/null 2>&1

    # Install QA dependencies
    log_info "Installing Django QA dependencies..."
    "$venv_pip" install -r "$COMPONENTS_DIR/backend/django/configs/requirements-qa.txt"

    log_success "Django QA tools installed"
}

install_go() {
    log_info "Setting up Go environment..."

    # Install Go tools
    log_info "Installing Go QA tools..."

    # Use go from PATH (includes mocked commands in tests)
    local go_cmd=$(/usr/bin/which go 2>/dev/null || echo "go")
    "$go_cmd" install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
    "$go_cmd" install github.com/securego/gosec/v2/cmd/gosec@latest

    log_success "Go QA tools installed"
}

install_frontend_component() {
    local component=$1
    local metadata=$2
    local component_dir=$3

    local package_file=$(echo "$metadata" | /opt/homebrew/bin/jq -r '.installation.package_file')

    cd "$TARGET_DIR"

    if [[ -n "$package_file" && -f "$package_file" ]]; then
        local dir=$(/usr/bin/dirname "$package_file")
        cd "$dir"

        log_info "Installing npm dependencies..."

        # Use npm from PATH (includes mocked commands in tests)
        local npm_cmd=$(/usr/bin/which npm 2>/dev/null || echo "npm")
        "$npm_cmd" install

        log_success "npm dependencies installed"
    fi
}

install_e2e_component() {
    local component=$1
    local metadata=$2
    local component_dir=$3

    local package_file=$(echo "$metadata" | /opt/homebrew/bin/jq -r '.installation.package_file')

    cd "$TARGET_DIR"

    if [[ -n "$package_file" && -f "$package_file" ]]; then
        local dir=$(/usr/bin/dirname "$package_file")
        cd "$dir"

        log_info "Installing npm dependencies..."

        # Use npm from PATH (includes mocked commands in tests)
        local npm_cmd=$(/usr/bin/which npm 2>/dev/null || echo "npm")
        "$npm_cmd" install

        # Run post-install commands
        while IFS= read -r cmd; do
            if [[ -n "$cmd" ]]; then
                log_info "Running: $cmd"
                eval "$cmd"
            fi
        done < <(echo "$metadata" | /opt/homebrew/bin/jq -r '.installation.post_install[]? // empty')

        log_success "E2E tools installed"
    fi
}

install_shared_component() {
    local component=$1
    local metadata=$2
    local component_dir=$3

    # Shared component just copies configs, no additional setup
    log_success "Shared configs installed"
}

install_precommit_framework() {
    log_info "Installing pre-commit framework..."

    cd "$TARGET_DIR"

    # Use pre-commit from PATH (includes mocked commands in tests)
    local precommit_cmd=$(/usr/bin/which pre-commit 2>/dev/null || echo "pre-commit")

    # Check if pre-commit is installed
    if ! /usr/bin/which pre-commit &> /dev/null; then
        log_info "Installing pre-commit globally..."
        local pip_cmd=$(/usr/bin/which pip 2>/dev/null || echo "pip")
        "$pip_cmd" install --user pre-commit
    fi

    # Install pre-commit hooks
    log_info "Installing pre-commit hooks..."
    "$precommit_cmd" install
    log_success "Pre-commit hooks installed"
}
