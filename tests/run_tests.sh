#!/opt/homebrew/bin/bash
set -euo pipefail

# fluxid QA Test Runner

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}                    fluxid QA Test Suite                              ${BLUE}║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check for bats
if ! command -v bats &> /dev/null; then
    echo -e "${RED}✗${NC} bats is not installed"
    echo ""
    echo "Install bats:"
    echo "  macOS:   brew install bats-core"
    echo "  Ubuntu:  sudo apt install bats"
    echo "  npm:     npm install -g bats"
    exit 1
fi

# Check for jq
if ! command -v jq &> /dev/null; then
    echo -e "${RED}✗${NC} jq is not installed"
    echo ""
    echo "Install jq:"
    echo "  macOS:   brew install jq"
    echo "  Ubuntu:  sudo apt install jq"
    exit 1
fi

FAILED=0

# Use bash 5.x for tests (required for associative arrays)
export BATS_TEST_SHELL=/opt/homebrew/bin/bash

# Run unit tests
echo -e "${BLUE}═══ Unit Tests ═══${NC}"
if bats tests/unit/; then
    echo -e "${GREEN}✓ Unit tests passed${NC}"
else
    echo -e "${RED}✗ Unit tests failed${NC}"
    FAILED=1
fi
echo ""

# Run integration tests
echo -e "${BLUE}═══ Integration Tests ═══${NC}"
if bats tests/integration/; then
    echo -e "${GREEN}✓ Integration tests passed${NC}"
else
    echo -e "${RED}✗ Integration tests failed${NC}"
    FAILED=1
fi
echo ""

# Run E2E tests
echo -e "${BLUE}═══ E2E Tests ═══${NC}"
if bats tests/e2e/; then
    echo -e "${GREEN}✓ E2E tests passed${NC}"
else
    echo -e "${RED}✗ E2E tests failed${NC}"
    FAILED=1
fi
echo ""

# Summary
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════════╗${NC}"
if [ $FAILED -eq 0 ]; then
    echo -e "${BLUE}║${NC}                ${GREEN}✓ All tests passed!${NC}                             ${BLUE}║${NC}"
else
    echo -e "${BLUE}║${NC}                ${RED}✗ Some tests failed${NC}                             ${BLUE}║${NC}"
fi
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════╝${NC}"

exit $FAILED
