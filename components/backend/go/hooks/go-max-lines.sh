#!/usr/bin/env bash
set -euo pipefail

# Go max lines: 400 prod, 600 tests

FILES=$(find . -type f -name '*.go' -not -path '*/vendor/*' -not -path '*/.git/*' -not -name '*.pb.go' -not -name '*_test.go')
TEST_FILES=$(find . -type f -name '*_test.go' -not -path '*/vendor/*' -not -path '*/.git/*')

for f in $FILES; do
  lines=$(wc -l < "$f" | tr -d '[:space:]')
  if [ "$lines" -gt 400 ]; then
    echo "Error: $f exceeds production limit (400 lines, found $lines)" >&2
    echo "MANDATORY: Split large files into smaller focused modules. DO NOT increase line limits." >&2
    exit 1
  fi
done

for f in $TEST_FILES; do
  lines=$(wc -l < "$f" | tr -d '[:space:]')
  if [ "$lines" -gt 600 ]; then
    echo "Error: $f exceeds test limit (600 lines, found $lines)" >&2
    echo "MANDATORY: Split large test files into smaller focused test modules. DO NOT increase line limits." >&2
    exit 1
  fi
done

exit 0
