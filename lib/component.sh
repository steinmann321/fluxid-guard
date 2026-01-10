#!/opt/homebrew/bin/bash
# Component discovery, loading, and detection functions

list_available_components() {
    /usr/bin/find "$COMPONENTS_DIR" -name "component.json" -type f | while read -r comp; do
        local dir=$(/usr/bin/dirname "$comp")
        local rel_path=${dir#$COMPONENTS_DIR/}
        /bin/echo "$rel_path"
    done
}

load_component_metadata() {
    local component=$1
    local metadata_file="$COMPONENTS_DIR/$component/component.json"

    if [[ ! -f "$metadata_file" ]]; then
        log_error "Component metadata not found: $component"
        return 1
    fi

    /bin/cat "$metadata_file"
}

detect_component() {
    local component=$1
    local metadata=$(load_component_metadata "$component")

    # Check if component has detection rules
    local always=$(echo "$metadata" | /opt/homebrew/bin/jq -r '.detection.always // false')
    if [[ "$always" == "true" ]]; then
        return 0
    fi

    cd "$TARGET_DIR"

    # Check for required files
    local files=$(echo "$metadata" | /opt/homebrew/bin/jq -r '.detection.files[]? // empty')
    for file in $files; do
        if [[ -f "$file" ]]; then
            log_info "Detected $component (found: $file)"
            return 0
        fi
    done

    # Check for required directories
    local dirs=$(echo "$metadata" | /opt/homebrew/bin/jq -r '.detection.directories[]? // empty')
    for dir in $dirs; do
        if [[ -d "$dir" ]]; then
            # Additional package indicator check if specified
            local pkg_file=$(echo "$metadata" | /opt/homebrew/bin/jq -r '.detection.package_indicators.file // empty')
            if [[ -n "$pkg_file" && -f "$pkg_file" ]]; then
                local contains=$(echo "$metadata" | /opt/homebrew/bin/jq -r '.detection.package_indicators.contains // empty')
                if grep -q "$contains" "$pkg_file" 2>/dev/null; then
                    log_info "Detected $component (found: $dir with $contains)"
                    return 0
                fi
            else
                log_info "Detected $component (found: $dir)"
                return 0
            fi
        fi
    done

    return 1
}

auto_detect_components() {
    local detected=()

    log_info "Auto-detecting components in: $TARGET_DIR"

    # Always include shared
    detected+=("shared")

    # Detect all available components
    while IFS= read -r component; do
        if [[ "$component" != "shared" ]] && detect_component "$component"; then
            detected+=("$component")
        fi
    done < <(list_available_components)

    printf '%s\n' "${detected[@]}"
}

load_preset() {
    local preset_name=$1
    local preset_file="$PRESETS_DIR/${preset_name}.json"

    if [[ ! -f "$preset_file" ]]; then
        log_error "Preset not found: $preset_name"
        log_info "Available presets:"
        ls -1 "$PRESETS_DIR"/*.json | xargs -n1 basename | /usr/bin/sed 's/.json$//' | /usr/bin/sed 's/^/  - /'
        exit 1
    fi

    log_success "Loading preset: $preset_name"

    # Load components from preset
    local components=$(/opt/homebrew/bin/jq -r '.components[]' "$preset_file")

    # Load configuration variables
    local config=$(/opt/homebrew/bin/jq -r '.configuration // {} | to_entries[] | "\(.key)=\(.value)"' "$preset_file")
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            local key=${line%%=*}
            local value=${line#*=}
            CONFIG_VARS[$key]=$value
        fi
    done <<< "$config"

    /bin/echo "$components"
}
