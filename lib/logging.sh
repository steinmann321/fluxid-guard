#!/opt/homebrew/bin/bash
# Logging and output functions

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

log_info() {
    printf "${BLUE}ℹ${NC} %s\n" "$1" >&2
}

log_success() {
    printf "${GREEN}✓${NC} %s\n" "$1" >&2
}

log_warning() {
    printf "${YELLOW}⚠${NC} %s\n" "$1" >&2
}

log_error() {
    printf "${RED}✗${NC} %s\n" "$1" >&2
}

print_header() {
    printf "\n"
    printf "${CYAN}╔══════════════════════════════════════════════════════════════════════╗${NC}\n"
    printf "${CYAN}║${NC}   ${BOLD}${MAGENTA}fluxid qa - Modular Component System${NC}                         ${CYAN}║${NC}\n"
    printf "${CYAN}║${NC}                                                                      ${CYAN}║${NC}\n"
    printf "${CYAN}║${NC}        ${GREEN}Enterprise-Grade QA for Multiple Tech Stacks${NC}             ${CYAN}║${NC}\n"
    printf "${CYAN}╚══════════════════════════════════════════════════════════════════════╝${NC}\n"
    printf "\n"
}

print_success_footer() {
    local components=("$@")

    printf "\n"
    printf "${GREEN}╔══════════════════════════════════════════════════════════════════════╗${NC}\n"
    printf "${GREEN}║${NC}                                                                      ${GREEN}║${NC}\n"
    printf "${GREEN}║${NC}     ${BOLD}${GREEN}✓${NC} ${BOLD}Enterprise-Grade QA Enforcement Activated!${NC}                  ${GREEN}║${NC}\n"
    printf "${GREEN}║${NC}                                                                      ${GREEN}║${NC}\n"
    printf "${GREEN}╚══════════════════════════════════════════════════════════════════════╝${NC}\n"
    printf "\n"
    printf "Installed components:\n"
    printf '  ✓ %s\n' "${components[@]}"
    printf "\n"
    printf "Next steps:\n"
    printf "  1. Review installed hooks: .hooks/\n"
    printf "  2. Test enforcement: /usr/bin/git add . && /usr/bin/git commit -m 'test'\n"
    printf "\n"
}
