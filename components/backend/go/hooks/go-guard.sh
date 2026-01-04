#!/usr/bin/env bash
set -euo pipefail

# Go Backend QA Guard: Strict quality enforcement for Go code

# 1) Go fmt check
echo "Checking Go formatting..."
out=$(gofmt -l . 2>&1 | grep -v vendor | grep -v .pb.go || true)
if [ -n "$out" ]; then
  echo "$out"
  echo "MANDATORY: Run 'gofmt -w .' on all Go files. DO NOT commit unformatted code." >&2
  exit 1
fi

# 2) Go vet (static analysis)
echo "Running go vet..."
go vet ./... || { echo "MANDATORY: Fix all go vet issues. These are potential bugs and errors." >&2; exit 1; }

# 3) golangci-lint (comprehensive linting)
echo "Running golangci-lint..."
golangci-lint run --config .golangci.yml || { echo "MANDATORY: Fix all linting issues detected by golangci-lint. DO NOT disable linters to bypass checks." >&2; exit 1; }

# 4) Test coverage (90% minimum)
echo "Running tests with coverage..."
go test -coverprofile=coverage.out -covermode=atomic ./... || { echo "Test failure detected. FIRST: Fix all failing tests - they must pass. SECOND: Add tests to reach minimum 90% coverage. DO NOT lower coverage thresholds." >&2; exit 1; }

coverage=$(go tool cover -func=coverage.out | grep total | awk '{print $3}' | sed 's/%//')
if (( $(echo "$coverage < 90" | bc -l) )); then
    echo "Coverage: ${coverage}% (minimum: 90%)" >&2
    echo "MANDATORY: Add tests to reach 90% coverage. DO NOT exclude files to game metrics." >&2
    exit 1
fi
rm -f coverage.out

# 5) gosec security scanner
echo "Running security scan..."
gosec -quiet ./... || { echo "MANDATORY: Fix all security issues found by gosec. Suppressing with #nosec is ONLY allowed for verified false positives with documented justification. NEVER suppress real security issues." >&2; exit 1; }

# 6) Go mod tidy check
echo "Checking go.mod..."
go mod tidy
if ! git diff --exit-code go.mod go.sum >/dev/null 2>&1; then
  echo "MANDATORY: Run 'go mod tidy' - go.mod or go.sum needs updating." >&2
  exit 1
fi

# 7) Max lines enforcement
"$(dirname "$0")/go-max-lines.sh" || exit 1

echo "✅ All Go QA checks passed"
exit 0
