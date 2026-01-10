#!/opt/homebrew/bin/bash
# Configuration variable handling

configure_variables() {
    local components=("$@")

    log_info "Configuration"

    for component in "${components[@]}"; do
        local metadata=$(load_component_metadata "$component")

        # Get variables defined by this component
        local vars=$(echo "$metadata" | /opt/homebrew/bin/jq -r '.variables | keys[]? // empty')

        for var in $vars; do
            # Skip if already configured (e.g., from preset)
            if [[ -n "${CONFIG_VARS[$var]:-}" ]]; then
                continue
            fi

            local default=$(echo "$metadata" | /opt/homebrew/bin/jq -r ".variables.$var.default")
            local prompt_text=$(echo "$metadata" | /opt/homebrew/bin/jq -r ".variables.$var.prompt")

            # In non-interactive mode (e.g., tests), automatically use defaults
            if [[ ! -t 0 ]]; then
                CONFIG_VARS[$var]=$default
                log_success "${var}: ${CONFIG_VARS[$var]}"
                continue
            fi

            printf "  %s (default: ${BOLD}%s${NC})\n" "$prompt_text" "$default" >&2
            read -p "  Use default ${default}? [Y/n]: " -r REPLY

            if [[ "$REPLY" =~ ^[Nn]$ ]]; then
                read -p "  Enter custom value: " custom_value
                CONFIG_VARS[$var]=$custom_value
            else
                CONFIG_VARS[$var]=$default
            fi

            log_success "${var}: ${CONFIG_VARS[$var]}"
        done
    done
}
