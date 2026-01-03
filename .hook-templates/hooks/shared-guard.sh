#!/usr/bin/env bash
set -euo pipefail

# Shared guard: secrets, semgrep (base + overlays), duplication, formatting
# Excludes: node_modules, dist, build, .venv, venv, coverage, .tmp, e2e-tests/test-results

# 1) Gitleaks (quiet on success)
out=$(bash -lc 'gitleaks detect --redact --config .gitleaks.toml --log-level=error --no-banner' 2>&1) || { printf "%s\n" "$out"; exit 1; }

# 2) Semgrep base + overlays (prod + e2e)
command -v backend/.venv/bin/semgrep >/dev/null 2>&1 || { echo "semgrep not found in backend venv" >&2; exit 1; }
backend/.venv/bin/semgrep --config .semgrep/base.yml --config .semgrep/e2e.yml --error --quiet --exclude node_modules --exclude dist --exclude build --exclude .venv --exclude venv --exclude coverage --exclude .tmp --exclude e2e-tests/test-results || { echo "Hint: Fix Semgrep violations." >&2; exit 1; }

# 3) Duplication gate
./frontend/node_modules/.bin/jscpd --config .jscpdrc frontend/src e2e-tests/tests >/dev/null || { echo "Hint: Refactor duplicate logic." >&2; exit 1; }

# 4) Prettier formatting checks (strict)
./frontend/node_modules/.bin/prettier --check "frontend/src/**/*.{ts,tsx,css}" >/dev/null || { echo "Hint: Run Prettier on frontend/src." >&2; exit 1; }
./frontend/node_modules/.bin/prettier --check "e2e-tests/**/*.{ts,tsx,js}" >/dev/null || { echo "Hint: Run Prettier on e2e-tests." >&2; exit 1; }

exit 0
