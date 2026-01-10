# fluxid-guard

**Quality enforcement for AI-generated codebases**

QA automation built on pre-commit framework, designed for full-stack Django + React + Playwright projects. Catches common AI-generated code issues before they enter your repository.

---

## Quick Start

Install fluxid-guard into any project:

```bash
# Clone and install in one step
git clone https://github.com/steinmann321/fluxid-guard.git /tmp/fluxid-guard
cd /tmp/fluxid-guard
./install.sh /path/to/your/project --preset django-react-playwright-v2
```

The installer adds 49 hooks with automatic dependency management to your project.

---

## What Gets Installed (v2 Architecture)

### Core Configs (pre-commit, gitleaks, semgrep, jscpd)
- Pre-commit framework with 49+ hooks
- Secrets detection (gitleaks)
- Security pattern matching (semgrep)
- Code duplication detection (jscpd)

### Backend QA (ruff, mypy, pytest, bandit, vulture, pip-audit)
Python dependencies installed to `backend/.venv`:
- **ruff** - Linting & formatting
- **mypy** - Strict static type checking (100% coverage)
- **pytest** - Testing with 90% coverage minimum
- **bandit** - Security vulnerability scanner
- **vulture** - Dead code detection
- **pip-audit** - Dependency vulnerability scan
- **autoflake** - Unused imports/variables removal
- **xenon** - Cyclomatic complexity limits
- **import-linter** - Architecture enforcement
- **semgrep** - Security pattern matching

### Frontend QA (TypeScript, ESLint, vitest, knip, dependency-cruiser)
JavaScript dependencies installed to `frontend/node_modules`:
- **TypeScript** - Type checking with 100% coverage
- **ESLint** - React/TypeScript linting (max-warnings=0)
- **vitest** - Testing with 90% coverage minimum
- **Prettier** - Code formatting
- **knip** - Unused files/exports detection
- **ts-unused-exports** - Export usage validation
- **dependency-cruiser** - Architecture validation
- **depcheck** - Dependency hygiene
- **stylelint** - CSS linting
- **type-coverage** - Type coverage enforcement

### E2E QA (Playwright tests, TypeScript checks)
E2E dependencies installed to `e2e-tests/node_modules`:
- **Playwright** - Browser automation testing
- **TypeScript** - Type checking (95% coverage)
- **ESLint** - Playwright-specific linting
- **Credentials verification** - Test environment validation

---

## Complete Rule List (49 Rules in 13 Phases)

### Phase 1: Fast Checks + Security (0-2 sec)
- Python syntax validation (AST)
- JSON/YAML/TOML validation
- Debug statements blocking (`console.log`, `pdb`)
- Whitespace/EOF normalization
- **Secrets detection** (API keys, passwords, tokens)

### Phase 2: Formatting (2-5 sec)
- Python formatting (ruff)
- Frontend formatting (prettier)
- E2E formatting (prettier)

### Phase 3: Dead Code Elimination (5-10 sec)
- Python dead code (vulture)
- Python unused imports/variables (autoflake)
- Frontend unused files (knip)
- Frontend unused exports (ts-unused-exports)

### Phase 4: Dependency Security (10-15 sec)
- **Python vulnerability scan** (pip-audit)
- **JavaScript vulnerability scan** (npm audit)
- Dependency hygiene (depcheck)

### Phase 5: File Size Limits (15-20 sec)
- Backend max 400 lines (600 for tests)
- Frontend max 400 lines (600 for tests)
- E2E max 600 lines

### Phase 6: Linting + Constants (20-30 sec)
- **Backend constants enforcement** (no hardcoded URLs/ports)
- Backend linting (ruff - 1000+ rules)
- **Bypass directive blocking** (no `# noqa`, `# type: ignore`)
- **Frontend constants enforcement** (semgrep)
- Frontend linting (ESLint - max-warnings=0)
- CSS linting (stylelint)
- **E2E constants enforcement** (semgrep)
- E2E linting (ESLint with Playwright rules)

### Phase 7: Type Safety (30-50 sec)
- **Backend strict typing** (mypy --strict, 100%)
- **Frontend TypeScript** (100% type coverage)
- Frontend type coverage enforcement
- **E2E TypeScript** (95% type coverage)
- E2E type coverage enforcement

### Phase 8: Complexity + Architecture (50-70 sec)
- Backend complexity limits (xenon - max B)
- Backend import boundaries (import-linter)
- Frontend architecture validation (dependency-cruiser)

### Phase 9: Framework-Specific (70-80 sec)
- **Django system checks** (models, settings, security)
- **Django migrations validation**
- **Backend security scan** (bandit - SQL injection, etc.)
- E2E credentials verification
- Fixture enforcement (migration-based only)

### Phase 10: Code Duplication (80-90 sec)
- Frontend + E2E duplication detection (jscpd)
- E2E standalone duplication check

### Phase 11: Test Coverage (90-150 sec)
- Backend TDD markers enforcement
- **Backend test coverage** (pytest - 90% min, branch coverage)
- **Frontend test coverage** (vitest - 90% min)

### Phase 12: Build Verification (150-180 sec)
- **Frontend production build** (Vite - tree-shaking, optimization)

### Phase 13: E2E Testing (180-240 sec)
- **Full E2E test suite** (Playwright - max-failures=1)

---

## Prerequisites

Your project structure should have:
```
your-project/
├── backend/          # Django app
│   ├── manage.py
│   └── requirements.txt
├── frontend/         # React + Vite + TypeScript
│   ├── package.json
│   └── src/
├── e2e-tests/        # Playwright tests
│   ├── package.json
│   └── tests/
└── Makefile          # With guard target
```

**Required tools:**
- Python 3.13+
- Node.js 22+
- Git
- Make

---

## Installation

### Method 1: Direct Installation (Recommended)

Install fluxid-guard into any existing project:

```bash
# 1. Ensure your project dependencies are installed first
cd /path/to/your/project
# Install backend dependencies (creates backend/.venv)
# Install frontend dependencies (creates frontend/node_modules)
# Install e2e dependencies (creates e2e-tests/node_modules)

# 2. Clone fluxid-guard and run installer
git clone https://github.com/steinmann321/fluxid-guard.git /tmp/fluxid-guard
cd /tmp/fluxid-guard
./install.sh /path/to/your/project --preset django-react-playwright-v2

# 3. Cleanup (optional)
rm -rf /tmp/fluxid-guard
```

**What the installer does:**
1. Detects your project structure (backend, frontend, e2e-tests)
2. Installs QA dependencies into existing `backend/.venv`
3. Installs frontend/E2E QA dependencies to `node_modules`
4. Copies pre-commit config (`.pre-commit-config.yaml`)
5. Copies security configs (`.gitleaks.toml`, `.jscpdrc`, `.semgrep/`)
6. Installs pre-commit hooks into your Git repository

### Method 2: Makefile Integration (Optional)

For convenience, add a `guard` target to your project's Makefile:

```makefile
# fluxid guard configuration
FLUXID_GUARD_REPO := https://github.com/steinmann321/fluxid-guard.git

guard:
	@if [ -z "$(PRESET)" ]; then \
		echo "[MAKE] ERROR: PRESET parameter is required"; \
		echo "[MAKE] Usage: make guard PRESET=<preset-name>"; \
		exit 1; \
	fi
	@echo "[MAKE] Cloning fluxid guard from GitHub..."
	@TEMP_DIR=$$(mktemp -d) && \
		git clone --quiet $(FLUXID_GUARD_REPO) "$$TEMP_DIR" && \
		echo "[MAKE] Installing fluxid guard with preset: $(PRESET)" && \
		cd "$$TEMP_DIR" && \
		echo "y" | ./install.sh $(CURDIR) --preset $(PRESET) && \
		cd $(CURDIR) && \
		rm -rf "$$TEMP_DIR" && \
		echo "[MAKE] fluxid guard installation complete"
```

Then install with:
```bash
make guard PRESET=django-react-playwright-v2
```

---

## Usage

### Run All Quality Checks

```bash
# Run all 49 rules before committing
pre-commit run --all-files
```

### Automatic on Git Commit

```bash
# Hooks run automatically on every commit
git add .
git commit -m "Add new feature"
# All 49 rules execute, fail-fast on first error
```

### Run Individual Tools

```bash
# Backend tools (from project root)
backend/.venv/bin/ruff check backend
backend/.venv/bin/mypy --strict backend
backend/.venv/bin/pytest --cov=backend --cov-fail-under=90

# Frontend tools
cd frontend && npm run lint
cd frontend && npm run type-check
cd frontend && npm run test:coverage

# E2E tools
cd e2e-tests && npx playwright test
```

---

## Example Output

```bash
$ git commit -m "Add user authentication"

check python ast.........................................................Passed
check json...............................................................Passed
shared — secrets detection...............................................Passed
backend — format check...................................................Passed
backend — dead code detection............................................Passed
backend — dependency vulnerability scan..................................Passed
backend — max lines (400 prod, 600 tests)...............................Passed
backend — ruff lint......................................................Passed
backend — mypy strict type check.........................................Passed
backend — complexity check...............................................Passed
backend — django system checks...........................................Passed
backend — security scan..................................................Passed
backend — test coverage (90% min)........................................Passed
frontend — prettier format check.........................................Passed
frontend — unused files check............................................Passed
frontend — security audit................................................Passed
frontend — eslint........................................................Passed
frontend — typescript typecheck..........................................Passed
frontend — type coverage (100%).........................................Passed
frontend — architecture validation.......................................Passed
frontend — test coverage (90%)..........................................Passed
frontend — production build..............................................Passed
e2e — eslint............................................................Passed
e2e — typescript typecheck...............................................Passed
e2e — playwright tests...................................................Passed

[main abc1234] Add user authentication
 15 files changed, 450 insertions(+), 20 deletions(-)
```

---

## Security Features

- **Secrets Detection**: Scans for API keys, passwords, tokens (gitleaks)
- **Vulnerability Scanning**: Checks Python (pip-audit) and JavaScript (npm audit) dependencies
- **Security Patterns**: Detects SQL injection, XSS, insecure functions (bandit, semgrep)
- **Bypass Prevention**: Blocks attempts to disable checks (`# noqa`, `type: ignore`)
- **Constants Enforcement**: Prevents hardcoded credentials, URLs, ports

---

## Architecture (v2)

The v2 architecture uses **pre-commit framework** exclusively:

```
.pre-commit-config.yaml    # 49 hooks in 13 phases
.hooks/                    # Custom hook scripts (read-only)
├── backend-max-lines.sh
├── check-bypass-directives.sh
└── frontend-max-lines.sh

.gitleaks.toml            # Secrets detection config
.jscpdrc                  # Code duplication config
.semgrep/                 # Security pattern rules
├── backend.yml
├── frontend.yml
└── e2e.yml

backend/.venv/            # Python QA tools
├── bin/ruff
├── bin/mypy
├── bin/pytest
├── bin/bandit
└── ...

frontend/node_modules/    # Frontend QA tools
e2e-tests/node_modules/   # E2E QA tools
```

---

## Re-installation / Updates

The installer automatically handles cleanup and reconfiguration. Simply run the installer again:

```bash
# Direct installation method
git clone https://github.com/steinmann321/fluxid-guard.git /tmp/fluxid-guard
cd /tmp/fluxid-guard
./install.sh /path/to/your/project --preset django-react-playwright-v2

# OR using Makefile (if integrated)
make guard PRESET=django-react-playwright-v2
```

To switch presets, just specify a different preset:
```bash
./install.sh /path/to/your/project --preset django-only
```

---

## Philosophy

**Built for AI-Generated Code:**
- LLMs like Claude generate significant portions of modern codebases
- AI code benefits from automated checks to catch common patterns
- Strict enforcement helps maintain code quality
- Fail-fast feedback helps AI learn correct patterns

**Why Strict Rules?**
- Prevents technical debt accumulation
- Catches issues before code review
- Enforces best practices automatically
- Creates consistent, maintainable codebase

---

## Contributing

Issues and PRs welcome at: https://github.com/steinmann321/fluxid-guard

---

## License

MIT License - See LICENSE file for details

---

## Related Projects

- **Django + React + Playwright Template**: https://github.com/steinmann321/django-react-playwright-template
  Complete starter with fluxid-guard installer preconfigured. Install QA enforcement with one command: `make guard PRESET=django-react-playwright-v2`

---

Built with care for AI-assisted development.
