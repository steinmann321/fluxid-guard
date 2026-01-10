# fluxid-guard

**Enterprise-grade quality enforcement for AI-generated codebases**

Zero-tolerance QA automation built on pre-commit framework, designed specifically for full-stack Django + React + Playwright projects. Catches common AI-generated code issues before they enter your repository.

---

## 🚀 Quick Start

Install all quality checks in one command:

```bash
# In your Django + React + Playwright project
make guard PRESET=django-react-playwright-v2
```

**That's it!** The guard system installs 49+ quality rules with automatic dependency management.

---

## 📋 What Gets Installed (v2 Architecture)

### **Core Configs** (pre-commit, gitleaks, semgrep, jscpd)
- Pre-commit framework with 49+ hooks
- Secrets detection (gitleaks)
- Security pattern matching (semgrep)
- Code duplication detection (jscpd)

### **Backend QA** (ruff, mypy, pytest, bandit, vulture, pip-audit)
Python dependencies installed to `backend/.venv`:
- **ruff** - Lightning-fast linting & formatting
- **mypy** - Strict static type checking (100% coverage)
- **pytest** - Testing with 90% coverage minimum
- **bandit** - Security vulnerability scanner
- **vulture** - Dead code detection
- **pip-audit** - Dependency vulnerability scan
- **autoflake** - Unused imports/variables removal
- **xenon** - Cyclomatic complexity limits
- **import-linter** - Architecture enforcement
- **semgrep** - Security pattern matching

### **Frontend QA** (TypeScript, ESLint, vitest, knip, dependency-cruiser)
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

### **E2E QA** (Playwright tests, TypeScript checks)
E2E dependencies installed to `e2e-tests/node_modules`:
- **Playwright** - Browser automation testing
- **TypeScript** - Type checking (95% coverage)
- **ESLint** - Playwright-specific linting
- **Credentials verification** - Test environment validation

---

## 🎯 Complete Rule List (49 Rules in 13 Phases)

### **Phase 1: Fast Checks + Security** (0-2 sec)
1. ✓ Python syntax validation (AST)
2. ✓ JSON/YAML/TOML validation
3. ✓ Debug statements blocking (`console.log`, `pdb`)
4. ✓ Whitespace/EOF normalization
5. ✓ **Secrets detection** (API keys, passwords, tokens)

### **Phase 2: Formatting** (2-5 sec)
6. ✓ Python formatting (ruff)
7. ✓ Frontend formatting (prettier)
8. ✓ E2E formatting (prettier)

### **Phase 3: Dead Code Elimination** (5-10 sec)
9. ✓ Python dead code (vulture)
10. ✓ Python unused imports/variables (autoflake)
11. ✓ Frontend unused files (knip)
12. ✓ Frontend unused exports (ts-unused-exports)

### **Phase 4: Dependency Security** (10-15 sec)
13. ✓ **Python vulnerability scan** (pip-audit)
14. ✓ **JavaScript vulnerability scan** (npm audit)
15. ✓ Dependency hygiene (depcheck)

### **Phase 5: File Size Limits** (15-20 sec)
16. ✓ Backend max 400 lines (600 for tests)
17. ✓ Frontend max 400 lines (600 for tests)
18. ✓ E2E max 600 lines

### **Phase 6: Linting + Constants** (20-30 sec)
19. ✓ **Backend constants enforcement** (no hardcoded URLs/ports)
20. ✓ Backend linting (ruff - 1000+ rules)
21. ✓ **Bypass directive blocking** (no `# noqa`, `# type: ignore`)
22. ✓ **Frontend constants enforcement** (semgrep)
23. ✓ Frontend linting (ESLint - max-warnings=0)
24. ✓ CSS linting (stylelint)
25. ✓ **E2E constants enforcement** (semgrep)
26. ✓ E2E linting (ESLint with Playwright rules)

### **Phase 7: Type Safety** (30-50 sec)
27. ✓ **Backend strict typing** (mypy --strict, 100%)
28. ✓ **Frontend TypeScript** (100% type coverage)
29. ✓ Frontend type coverage enforcement
30. ✓ **E2E TypeScript** (95% type coverage)
31. ✓ E2E type coverage enforcement

### **Phase 8: Complexity + Architecture** (50-70 sec)
32. ✓ Backend complexity limits (xenon - max B)
33. ✓ Backend import boundaries (import-linter)
34. ✓ Frontend architecture validation (dependency-cruiser)

### **Phase 9: Framework-Specific** (70-80 sec)
35. ✓ **Django system checks** (models, settings, security)
36. ✓ **Django migrations validation**
37. ✓ **Backend security scan** (bandit - SQL injection, etc.)
38. ✓ E2E credentials verification
39. ✓ Fixture enforcement (migration-based only)

### **Phase 10: Code Duplication** (80-90 sec)
40. ✓ Frontend + E2E duplication detection (jscpd)
41. ✓ E2E standalone duplication check

### **Phase 11: Test Coverage** (90-150 sec)
42. ✓ Backend TDD markers enforcement
43. ✓ **Backend test coverage** (pytest - 90% min, branch coverage)
44. ✓ **Frontend test coverage** (vitest - 90% min)

### **Phase 12: Build Verification** (150-180 sec)
45. ✓ **Frontend production build** (Vite - tree-shaking, optimization)

### **Phase 13: E2E Testing** (180-240 sec)
46. ✓ **Full E2E test suite** (Playwright - max-failures=1)

---

## 📦 Prerequisites

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

## 🔧 Installation

### Step 1: Add Guard Target to Makefile

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

### Step 2: Install Dependencies

```bash
# Install your app dependencies first
make setup  # or npm install, pip install, etc.
```

### Step 3: Install Guard System

```bash
# Install all QA rules (one command, fully automated)
make guard PRESET=django-react-playwright-v2
```

**What happens:**
1. Clones fluxid-guard from GitHub to temporary directory
2. Installs 100+ Python QA dependencies to `backend/.venv`
3. Installs frontend/E2E QA dependencies to `node_modules`
4. Configures pre-commit hooks (`.pre-commit-config.yaml`)
5. Sets up configs (`.gitleaks.toml`, `.jscpdrc`, `.semgrep/`)
6. Cleans up temporary files

---

## 🎮 Usage

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
# → All 49 rules execute, fail-fast on first error
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

## 📖 Available Presets

| Preset | Description | Components |
|--------|-------------|------------|
| `django-react-playwright-v2` | Full-stack (recommended) | Backend, Frontend, E2E, Configs |
| `django-react-playwright` | Full-stack (legacy) | Older architecture |
| `django-only` | Backend only | Django + Python QA |
| `go-only` | Go backend | Go + QA tools |

---

## 🔍 Example Output

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

## 🛡️ Security Features

- **Secrets Detection**: Scans for API keys, passwords, tokens (gitleaks)
- **Vulnerability Scanning**: Checks Python (pip-audit) and JavaScript (npm audit) dependencies
- **Security Patterns**: Detects SQL injection, XSS, insecure functions (bandit, semgrep)
- **Bypass Prevention**: Blocks attempts to disable checks (`# noqa`, `type: ignore`)
- **Constants Enforcement**: Prevents hardcoded credentials, URLs, ports

---

## 🏗️ Architecture (v2)

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

**Key Differences from v1:**
- ✅ Pre-commit framework handles all orchestration
- ✅ No separate "guard" scripts
- ✅ Phased execution (fail-fast)
- ✅ Shared configs across all components
- ✅ Integrated into existing venvs/node_modules

---

## 🔄 Re-installation / Updates

```bash
# Update to latest version
make guard PRESET=django-react-playwright-v2

# Switch to different preset
make guard PRESET=django-only

# The installer handles cleanup and reconfiguration automatically
```

---

## 🐛 Troubleshooting

### Issue: "No module named 'ruff'"
**Solution**: Run `make setup` first to create `backend/.venv`, then run `make guard`

### Issue: Pre-commit hook fails on first run
**Solution**: First run installs pre-commit environments. Run again:
```bash
pre-commit run --all-files
```

### Issue: "PRESET parameter is required"
**Solution**: Always specify preset:
```bash
make guard PRESET=django-react-playwright-v2
```

### Issue: Hooks take too long
**Solution**: Hooks cache results. Subsequent runs are much faster. To skip on CI:
```bash
SKIP=frontend-vite-build,e2e-playwright git commit -m "..."
```

---

## 📚 Philosophy

**Built for AI-Generated Code:**
- LLMs like Claude generate significant portions of modern codebases
- AI code needs stricter enforcement to catch common patterns
- Zero-tolerance policy prevents gradual quality degradation
- Fail-fast feedback helps AI learn correct patterns

**Why Strict Rules?**
- Prevents technical debt accumulation
- Catches issues before code review
- Enforces best practices automatically
- Creates consistent, maintainable codebase

---

## 🤝 Contributing

Issues and PRs welcome at: https://github.com/steinmann321/fluxid-guard

---

## 📄 License

MIT License - See LICENSE file for details

---

## 🔗 Related Projects

- **Bootstrap Template**: https://github.com/steinmann321/django-react-playwright-template
- **Scaffold with Guard**: Complete starter with fluxid-guard pre-configured

---

**Built with ❤️ for AI-assisted development**
