#!/opt/homebrew/bin/bash
set -euo pipefail

# FluxID QA - Modular Component System Installer
# Entry point for installation script

# Determine script directory
SCRIPT_DIR="$(cd "$(/usr/bin/dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPONENTS_DIR="${SCRIPT_DIR}/components"
PRESETS_DIR="${SCRIPT_DIR}/presets"

# Target directory and configuration
TARGET_DIR=""
SELECTED_COMPONENTS=()
declare -A CONFIG_VARS
MODE=""
PRESET=""
MANUAL_COMPONENTS=""

# Source library modules
source "${SCRIPT_DIR}/lib/logging.sh"
source "${SCRIPT_DIR}/lib/component.sh"
source "${SCRIPT_DIR}/lib/validation.sh"
source "${SCRIPT_DIR}/lib/config.sh"
source "${SCRIPT_DIR}/lib/install.sh"
source "${SCRIPT_DIR}/lib/main.sh"

# Execute main function
main "$@"
