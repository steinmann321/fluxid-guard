#!/usr/bin/env bash
set -euo pipefail

# Bypass directive enforcement: Block blanket, allow specific
# Designed for LLM-managed codebase

BACKEND_DIR="backend"
EXIT_CODE=0

echo "Checking for blanket bypass directives..."

# ============================================================================
# BLOCKED: Blanket bypasses (no error code specified)
# ============================================================================

# Pattern 1: # type: ignore (without [error-code])
if grep -rn -E '# type: ignore\s*($|[^[]|#)' "$BACKEND_DIR" \
  --exclude-dir=.venv --exclude-dir=migrations --exclude-dir=__pycache__ \
  --include="*.py" 2>/dev/null | head -1 > /dev/null; then

  echo "❌ ERROR: Blanket '# type: ignore' found (must specify error code):"
  grep -rn -E '# type: ignore\s*($|[^[]|#)' "$BACKEND_DIR" \
    --exclude-dir=.venv --exclude-dir=migrations --exclude-dir=__pycache__ \
    --include="*.py" 2>/dev/null
  echo "Fix: ❌ # type: ignore → ✅ # type: ignore[return-value]"
  EXIT_CODE=1
fi

# Pattern 2: # noqa (without error code)
if grep -rn -E '# noqa\s*($|[^:]|#)' "$BACKEND_DIR" \
  --exclude-dir=.venv --exclude-dir=migrations --exclude-dir=__pycache__ \
  --include="*.py" 2>/dev/null | head -1 > /dev/null; then

  echo "❌ ERROR: Blanket '# noqa' found (must specify error code):"
  grep -rn -E '# noqa\s*($|[^:]|#)' "$BACKEND_DIR" \
    --exclude-dir=.venv --exclude-dir=migrations --exclude-dir=__pycache__ \
    --include="*.py" 2>/dev/null
  echo "Fix: ❌ # noqa → ✅ # noqa: S105"
  EXIT_CODE=1
fi

# Pattern 3: # nosec (without issue code)
if grep -rn -E '# nosec\s*($|[^B]|#)' "$BACKEND_DIR" \
  --exclude-dir=.venv --exclude-dir=migrations --exclude-dir=__pycache__ \
  --include="*.py" 2>/dev/null | head -1 > /dev/null; then

  echo "❌ ERROR: Blanket '# nosec' found (must specify issue code):"
  grep -rn -E '# nosec\s*($|[^B]|#)' "$BACKEND_DIR" \
    --exclude-dir=.venv --exclude-dir=migrations --exclude-dir=__pycache__ \
    --include="*.py" 2>/dev/null
  echo "Fix: ❌ # nosec → ✅ # nosec B603"
  EXIT_CODE=1
fi

# ============================================================================
# BLOCKED: File-level blanket bypasses
# ============================================================================

# Whitelist for files where file-level bypasses are legitimately needed
WHITELIST_FILES=(
  "vulture_whitelist.py"  # Vulture whitelist files contain undefined names by design
  "*/constants/*"          # Constants files may contain literals and undefined references
)

# Helper function to filter out whitelisted files
filter_whitelist() {
  local results="$1"

  if [ -z "$results" ]; then
    echo ""
    return
  fi

  local filtered="$results"

  for pattern in "${WHITELIST_FILES[@]}"; do
    # Convert shell pattern to grep-compatible regex
    # */constants/* becomes .*/constants/.*
    local grep_pattern=$(echo "$pattern" | sed 's|\*/|.*/|g' | sed 's|\*|.*|g')
    filtered=$(echo "$filtered" | grep -v "$grep_pattern" || true)
  done

  echo "$filtered"
}

# Pattern 4: # mypy: ignore-errors (file-level mypy bypass)
MYPY_RESULTS=$(grep -rn -E '^\s*#\s*mypy:\s*ignore-errors' "$BACKEND_DIR" \
  --exclude-dir=.venv --exclude-dir=migrations --exclude-dir=__pycache__ \
  --include="*.py" 2>/dev/null || true)
MYPY_FILTERED=$(filter_whitelist "$MYPY_RESULTS")

if [ -n "$MYPY_FILTERED" ]; then
  echo "❌ ERROR: File-level '# mypy: ignore-errors' found (use specific # type: ignore[error-code] instead):"
  echo "$MYPY_FILTERED"
  echo ""
  echo "Fix: Remove file-level bypass and use specific # type: ignore[error-code] on individual lines"
  echo ""
  echo "⚠️  LAST RESORT ONLY: If ALL other options are exhausted (generated code, dead code whitelists),"
  echo "    and you've confirmed there is absolutely no alternative, add to WHITELIST_FILES in"
  echo "    .hooks/check-bypass-directives.sh with detailed justification explaining why this is unavoidable."
  echo "    Exceptions should be avoided at all costs - only add if truly impossible to fix otherwise."
  EXIT_CODE=1
fi

# Pattern 5: # pylint: skip-file (file-level pylint bypass)
PYLINT_RESULTS=$(grep -rn -E '^\s*#\s*pylint:\s*skip-file' "$BACKEND_DIR" \
  --exclude-dir=.venv --exclude-dir=migrations --exclude-dir=__pycache__ \
  --include="*.py" 2>/dev/null || true)
PYLINT_FILTERED=$(filter_whitelist "$PYLINT_RESULTS")

if [ -n "$PYLINT_FILTERED" ]; then
  echo "❌ ERROR: File-level '# pylint: skip-file' found (use specific # pylint: disable=error-name instead):"
  echo "$PYLINT_FILTERED"
  echo ""
  echo "Fix: Remove file-level bypass and use specific # pylint: disable=error-name on individual lines"
  echo ""
  echo "⚠️  LAST RESORT ONLY: If ALL other options are exhausted (generated code, dead code whitelists),"
  echo "    and you've confirmed there is absolutely no alternative, add to WHITELIST_FILES in"
  echo "    .hooks/check-bypass-directives.sh with detailed justification explaining why this is unavoidable."
  echo "    Exceptions should be avoided at all costs - only add if truly impossible to fix otherwise."
  EXIT_CODE=1
fi

# Pattern 6: # flake8: noqa (file-level flake8 bypass)
FLAKE8_RESULTS=$(grep -rn -E '^\s*#\s*flake8:\s*noqa\s*$' "$BACKEND_DIR" \
  --exclude-dir=.venv --exclude-dir=migrations --exclude-dir=__pycache__ \
  --include="*.py" 2>/dev/null || true)
FLAKE8_FILTERED=$(filter_whitelist "$FLAKE8_RESULTS")

if [ -n "$FLAKE8_FILTERED" ]; then
  echo "❌ ERROR: File-level '# flake8: noqa' found (use specific # noqa: CODE on individual lines):"
  echo "$FLAKE8_FILTERED"
  echo ""
  echo "Fix: Remove file-level bypass and use specific # noqa: CODE on individual lines"
  echo ""
  echo "⚠️  LAST RESORT ONLY: If ALL other options are exhausted (generated code, dead code whitelists),"
  echo "    and you've confirmed there is absolutely no alternative, add to WHITELIST_FILES in"
  echo "    .hooks/check-bypass-directives.sh with detailed justification explaining why this is unavoidable."
  echo "    Exceptions should be avoided at all costs - only add if truly impossible to fix otherwise."
  EXIT_CODE=1
fi

# Pattern 7: # ruff: noqa (blanket file-level ruff bypass without specific codes)
RUFF_RESULTS=$(grep -rn -E '^\s*#\s*ruff:\s*noqa\s*$' "$BACKEND_DIR" \
  --exclude-dir=.venv --exclude-dir=migrations --exclude-dir=__pycache__ \
  --include="*.py" 2>/dev/null || true)
RUFF_FILTERED=$(filter_whitelist "$RUFF_RESULTS")

if [ -n "$RUFF_FILTERED" ]; then
  echo "❌ ERROR: File-level blanket '# ruff: noqa' found (must specify error codes like # ruff: noqa: F821, E501):"
  echo "$RUFF_FILTERED"
  echo ""
  echo "Fix: ❌ # ruff: noqa → ✅ # ruff: noqa: F821, E501 (specify error codes)"
  echo ""
  echo "⚠️  LAST RESORT ONLY: If ALL other options are exhausted (generated code, dead code whitelists),"
  echo "    and you've confirmed there is absolutely no alternative, add to WHITELIST_FILES in"
  echo "    .hooks/check-bypass-directives.sh with detailed justification explaining why this is unavoidable."
  echo "    Exceptions should be avoided at all costs - only add if truly impossible to fix otherwise."
  EXIT_CODE=1
fi

# ============================================================================
# Results
# ============================================================================

if [ $EXIT_CODE -eq 0 ]; then
  echo "✅ No blanket bypasses found"
fi

exit $EXIT_CODE
