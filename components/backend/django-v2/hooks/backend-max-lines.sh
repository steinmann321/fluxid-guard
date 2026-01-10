#!/usr/bin/env bash
set -euo pipefail
FILES=$(find backend -type f -name '*.py' -not -path '*/.*' -not -path '*/migrations/*' -not -path '*/__pycache__/*')
for f in $FILES; do
  lines=$(wc -l < "$f" | tr -d '[:space:]')
  if [[ "$f" == *test*.py ]] || [[ "$f" == *conftest.py ]]; then
    [ "$lines" -le 600 ] || { echo "Error: $f exceeds test limit (600 lines, found $lines)" >&2; exit 1; }
  else
    [ "$lines" -le 400 ] || { echo "Error: $f exceeds production limit (400 lines, found $lines)" >&2; exit 1; }
  fi
done
exit 0
