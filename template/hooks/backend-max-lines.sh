#!/usr/bin/env bash
set -euo pipefail

# Backend max lines: 400 prod, 600 tests
#
# Exclusions (technical only - NOT user code):
# - migrations/ : Django auto-generated
# - __pycache__/ : Python bytecode
# - .* : Hidden files (not source code)
#
# DO NOT ADD MORE EXCLUSIONS - if file is too long, refactor it
# Test files get higher limit (600 vs 400) but still enforced

FILES=$(find backend -type f -name '*.py' -not -path '*/.*' -not -path '*/migrations/*' -not -path '*/__pycache__/*')

for f in $FILES; do
  lines=$(wc -l < "$f" | tr -d '[:space:]')

  # Test files can be up to 600 lines
  if [[ "$f" == *test*.py ]] || [[ "$f" == *conftest.py ]]; then
    if [ "$lines" -gt 600 ]; then
      echo "Error: $f exceeds test limit (600 lines, found $lines)" >&2
      echo "Hint: Split large test files into smaller focused test modules." >&2
      exit 1
    fi
  else
    # Production files limited to 400 lines
    if [ "$lines" -gt 400 ]; then
      echo "Error: $f exceeds production limit (400 lines, found $lines)" >&2
      echo "Hint: Split large files into smaller focused modules." >&2
      exit 1
    fi
  fi
done

exit 0
