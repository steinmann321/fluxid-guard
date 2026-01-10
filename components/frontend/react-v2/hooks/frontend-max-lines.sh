#!/usr/bin/env bash
set -euo pipefail
PROD_LIMIT=400
TEST_LIMIT=600
cd frontend
fail() { echo "Error: $1 exceeds limit (${2} lines)" >&2; exit 1; }
is_test() { case "$1" in *.test.ts|*.test.tsx|*.spec.ts|*.spec.tsx) return 0;; *) return 1;; esac }
while IFS= read -r -d '' file; do
  lines=$(wc -l < "$file" | tr -d '[:space:]')
  if is_test "$file"; then [ "$lines" -le "$TEST_LIMIT" ] || fail "$file" "$lines"; else [ "$lines" -le "$PROD_LIMIT" ] || fail "$file" "$lines"; fi
done < <(find src -type f -print0)
exit 0
