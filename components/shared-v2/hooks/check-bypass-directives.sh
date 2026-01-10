#!/usr/bin/env bash
set -euo pipefail

# Bypass directive enforcement: Block blanket, allow specific
# Designed for LLM-managed codebase

BACKEND_DIR="backend"
EXIT_CODE=0

echo "Checking for blanket bypass directives..."

# BLOCKED: Blanket bypasses (no error code specified)
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

if [ $EXIT_CODE -eq 0 ]; then
  echo "✅ No blanket bypasses found"
fi

exit $EXIT_CODE
