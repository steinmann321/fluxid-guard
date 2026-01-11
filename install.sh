#!/bin/bash
set -euo pipefail

# fluxid guard - Simple Installation
# Usage: ./install.sh [target_dir] [--config config.yaml]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${1:-.}"
CONFIG_FILE=""

# Default paths
BACKEND_DIR="backend"
FRONTEND_DIR="frontend"
E2E_DIR="e2e-tests"
HOOKS_DIR=".hooks"
SEMGREP_DIR=".semgrep"

# Parse arguments
shift || true
while [[ $# -gt 0 ]]; do
    case $1 in
        --config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: ./install.sh [target_dir] [--config config.yaml]"
            exit 1
            ;;
    esac
done

# Read config if exists
if [ -n "$CONFIG_FILE" ] && [ -f "$CONFIG_FILE" ]; then
    echo "Reading configuration from $CONFIG_FILE..."
    # Simple YAML parser for our limited needs
    BACKEND_DIR=$(grep "^\s*backend:" "$CONFIG_FILE" | head -1 | sed 's/.*backend:\s*"\?\([^"]*\)"\?.*/\1/' || echo "$BACKEND_DIR")
    FRONTEND_DIR=$(grep "^\s*frontend:" "$CONFIG_FILE" | head -1 | sed 's/.*frontend:\s*"\?\([^"]*\)"\?.*/\1/' || echo "$FRONTEND_DIR")
    E2E_DIR=$(grep "^\s*e2e:" "$CONFIG_FILE" | head -1 | sed 's/.*e2e:\s*"\?\([^"]*\)"\?.*/\1/' || echo "$E2E_DIR")
    HOOKS_DIR=$(grep "^\s*hooks:" "$CONFIG_FILE" | head -1 | sed 's/.*hooks:\s*"\?\([^"]*\)"\?.*/\1/' || echo "$HOOKS_DIR")
    SEMGREP_DIR=$(grep "^\s*semgrep:" "$CONFIG_FILE" | head -1 | sed 's/.*semgrep:\s*"\?\([^"]*\)"\?.*/\1/' || echo "$SEMGREP_DIR")
fi

echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║        fluxid guard - Quality Enforcement Setup          ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "Target directory: $TARGET_DIR"
echo "Backend:          $BACKEND_DIR/"
echo "Frontend:         $FRONTEND_DIR/"
echo "E2E Tests:        $E2E_DIR/"
echo "Hooks:            $HOOKS_DIR/"
echo "Semgrep:          $SEMGREP_DIR/"
echo ""

cd "$TARGET_DIR"

# 1. Copy pre-commit config with path substitution
echo "[1/6] Installing pre-commit configuration..."
sed -e "s|{{BACKEND_DIR}}|$BACKEND_DIR|g" \
    -e "s|{{FRONTEND_DIR}}|$FRONTEND_DIR|g" \
    -e "s|{{E2E_DIR}}|$E2E_DIR|g" \
    "$SCRIPT_DIR/template/.pre-commit-config.yaml" > .pre-commit-config.yaml
echo "      ✓ .pre-commit-config.yaml"

# 2. Copy hook scripts
echo "[2/6] Installing custom hooks..."
mkdir -p "$HOOKS_DIR"
cp "$SCRIPT_DIR/template/hooks/"* "$HOOKS_DIR/"
chmod +x "$HOOKS_DIR"/*.sh "$HOOKS_DIR"/*.py 2>/dev/null || true
echo "      ✓ Custom hooks copied to $HOOKS_DIR/"

# 3. Copy semgrep configs
echo "[3/6] Installing semgrep rules..."
mkdir -p "$SEMGREP_DIR"
cp "$SCRIPT_DIR/template/semgrep/"* "$SEMGREP_DIR/"
echo "      ✓ Semgrep rules copied to $SEMGREP_DIR/"

# 4. Copy other configs
echo "[4/6] Installing supporting configs..."
cp "$SCRIPT_DIR/template/.gitleaks.toml" .gitleaks.toml
cp "$SCRIPT_DIR/template/.jscpdrc" .jscpdrc
echo "      ✓ .gitleaks.toml"
echo "      ✓ .jscpdrc"

# 5. Install pre-commit hooks
echo "[5/6] Installing pre-commit hooks..."
if ! command -v pre-commit &> /dev/null; then
    echo ""
    echo "❌ ERROR: pre-commit not found"
    echo ""
    echo "Install pre-commit first:"
    echo "  pip install pre-commit"
    echo ""
    echo "or"
    echo ""
    echo "  brew install pre-commit"
    echo ""
    exit 1
fi
pre-commit install
echo "      ✓ Pre-commit hooks installed"

# 6. Validate structure
echo "[6/6] Validating project structure..."
MISSING=()
WARNINGS=""

[ ! -d "$BACKEND_DIR" ] && MISSING+=("$BACKEND_DIR")
[ ! -d "$FRONTEND_DIR" ] && MISSING+=("$FRONTEND_DIR")
[ ! -d "$E2E_DIR" ] && MISSING+=("$E2E_DIR")

# Check for dependency files
[ ! -d "$BACKEND_DIR" ] || [ ! -f "$BACKEND_DIR/.venv/bin/python" ] && WARNINGS="$WARNINGS\n  - Backend virtualenv not found at $BACKEND_DIR/.venv/"
[ ! -d "$FRONTEND_DIR" ] || [ ! -d "$FRONTEND_DIR/node_modules" ] && WARNINGS="$WARNINGS\n  - Frontend node_modules not found in $FRONTEND_DIR/"
[ ! -d "$E2E_DIR" ] || [ ! -d "$E2E_DIR/node_modules" ] && WARNINGS="$WARNINGS\n  - E2E node_modules not found in $E2E_DIR/"

if [ ${#MISSING[@]} -gt 0 ]; then
    echo ""
    echo "⚠️  WARNING: Expected directories not found:"
    for dir in "${MISSING[@]}"; do
        echo "      - $dir/"
    done
fi

if [ -n "$WARNINGS" ]; then
    echo ""
    echo "⚠️  WARNING: Dependencies may not be installed:"
    echo -e "$WARNINGS"
fi

echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                  ✅ Installation Complete                 ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

if [ ${#MISSING[@]} -gt 0 ] || [ -n "$WARNINGS" ]; then
    echo "⚠️  Next steps:"
    echo ""
    if [ ${#MISSING[@]} -gt 0 ]; then
        echo "1. Create missing directories or update config.yaml with correct paths"
        echo ""
    fi
    if [ -n "$WARNINGS" ]; then
        echo "2. Install dependencies:"
        echo ""
        [ -d "$BACKEND_DIR" ] && echo "   Backend:  cd $BACKEND_DIR && python -m venv .venv && .venv/bin/pip install -r requirements-dev.txt"
        [ -d "$FRONTEND_DIR" ] && echo "   Frontend: cd $FRONTEND_DIR && npm install"
        [ -d "$E2E_DIR" ] && echo "   E2E:      cd $E2E_DIR && npm install"
        echo ""
    fi
    echo "3. Test the hooks:"
    echo "   pre-commit run --all-files"
    echo ""
else
    echo "🎉 You're all set! Test the hooks:"
    echo ""
    echo "   pre-commit run --all-files"
    echo ""
fi
