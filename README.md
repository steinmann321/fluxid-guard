# fluxid Guard

**Production-grade quality enforcement for Django + React + Playwright projects**

fluxid guard is a comprehensive, pre-commit-based quality gate system that enforces code quality, security, and architectural standards across your full-stack application. Based on battle-tested configurations from real-world projects, it provides instant setup and complete validation on every commit.

## What It Does

- ✅ **100% Quality Gate Coverage**: Every commit runs the full validation suite
- ✅ **Zero Bypass Holes**: All checks use `always_run: true` for comprehensive enforcement
- ✅ **Fast Fail**: 13 sequential phases designed to fail fast on critical issues
- ✅ **Multi-Language Support**: Python (Django), TypeScript/React, Playwright E2E
- ✅ **Security First**: Secrets detection, dependency audits, security scanning
- ✅ **Architecture Enforcement**: Constants, imports, complexity, test coverage
- ✅ **Framework-Aware**: Smart exclusions for React JSX, Django ORM, Playwright locators

## Quick Start

### Default Layout (Recommended)

If your project follows this structure:
```
your-project/
├── backend/          # Django application
├── frontend/         # React application
└── e2e-tests/        # Playwright tests
```

Install with one command:

```bash
cd your-project
curl -fsSL https://raw.githubusercontent.com/steinmann321/fluxid-guard/main/install.sh | bash
```

### Custom Layout

If your project uses different paths:

```bash
# Download install script
curl -fsSL https://raw.githubusercontent.com/steinmann321/fluxid-guard/main/install.sh -o install.sh
curl -fsSL https://raw.githubusercontent.com/steinmann321/fluxid-guard/main/examples/config.yaml.custom -o fluxid-config.yaml

# Edit config.yaml with your paths
nano fluxid-config.yaml

# Install
chmod +x install.sh
./install.sh . --config fluxid-config.yaml
```

## Installation

### Prerequisites

1. **pre-commit** (required):
   ```bash
   pip install pre-commit
   # or
   brew install pre-commit
   ```

2. **Project dependencies** (required for hooks to run):
   - Backend: Python virtualenv at `backend/.venv/` with dev dependencies
   - Frontend: `node_modules/` with all dependencies
   - E2E: `node_modules/` with Playwright installed

### Install fluxid guard

```bash
# Clone or download this repository
git clone https://github.com/steinmann321/fluxid-guard.git /tmp/fluxid-guard

# Navigate to your project
cd /path/to/your/project

# Run installer
/tmp/fluxid-guard/install.sh

# Test installation
pre-commit run --all-files
```

## Configuration

### Default Paths

fluxid guard assumes this structure by default:
```yaml
paths:
  backend: "backend"
  frontend: "frontend"
  e2e: "e2e-tests"
  hooks: ".hooks"
  semgrep: ".semgrep"
```

### Custom Paths

Create a `fluxid-config.yaml`:

```yaml
# Example: Custom layout
paths:
  backend: "server"
  frontend: "client"
  e2e: "tests/e2e"
  hooks: ".hooks"
  semgrep: ".semgrep"
```

Then install with:
```bash
./install.sh . --config fluxid-config.yaml
```

### Example Configurations

See `examples/` directory for common layouts:
- `config.yaml.default` - Standard Django + React + Playwright
- `config.yaml.custom` - Custom server/client naming
- `config.yaml.monorepo` - Nested services/packages structure

## What Gets Installed

After installation, your project will have:

```
your-project/
├── .pre-commit-config.yaml          # Main config (fail-fast enabled)
├── .pre-commit-config-full.yaml     # Full run config (no fail-fast)
├── .gitleaks.toml                   # Secrets detection rules
├── .jscpdrc                         # Code duplication thresholds
├── .hooks/                    # Custom validation scripts
│   ├── backend-max-lines.sh
│   ├── frontend-max-lines.sh
│   ├── backend-tdd-tags.py
│   ├── check-bypass-directives.sh
│   └── enforce-migration-fixtures.sh
└── .semgrep/                  # Constants enforcement rules
    ├── backend.yml
    ├── frontend.yml            # Includes test ID enforcement
    └── e2e.yml
```

## Configuration Modes

### Default: Fail-Fast (`.pre-commit-config.yaml`)
**Use for:** Regular commits, day-to-day development

Stops at first failure for quick feedback:
```bash
git commit  # Uses default config automatically
```

**Behavior:**
- Stops immediately on first error
- Fast feedback (10-30 seconds typical)
- Developer-friendly iteration

### Full Run Mode (`.pre-commit-config-full.yaml`)
**Use for:** Initial audits, reporting, coverage tools, CI dashboards

Runs all checks regardless of failures:
```bash
# One-time full audit
SKIP= pre-commit run --all-files --config .pre-commit-config-full.yaml

# See all violations across entire codebase
pre-commit run --all-files --config .pre-commit-config-full.yaml 2>&1 | tee audit-report.txt

# CI/CD full scan
pre-commit run --all-files --config .pre-commit-config-full.yaml --show-diff-on-failure
```

**Behavior:**
- Runs all 13 phases completely
- Shows all violations (not just first)
- Generates complete picture for metrics
- Slower (3-5 minutes full run)

**Use cases:**
- Initial project audit: "Show me all current violations"
- Coverage reports: "What's our overall compliance?"
- CI metrics: Track violation trends over time
- Documentation: Generate compliance reports

## Validation Phases

fluxid guard runs 13 sequential phases designed to fail fast:

### Phase 1: Syntactic Checks + Security (0-2s)
- AST validation
- JSON/YAML/TOML syntax
- Debug statements check
- **Secrets detection** (gitleaks)

### Phase 2: Formatting (2-5s)
- Ruff format (Python)
- Prettier (TypeScript/React/E2E)

### Phase 3: Dead Code Elimination (5-10s)
- Vulture (Python unused code)
- Autoflake (Python unused imports)
- Knip (TypeScript unused files)
- ts-unused-exports (TypeScript unused exports)

### Phase 4: Dependency Audits (10-15s)
- pip-audit (Python vulnerabilities)
- npm audit (JavaScript vulnerabilities)
- depcheck (Dependency hygiene)

### Phase 5: Simple Metrics (15-20s)
- Max lines enforcement (400 prod, 600 tests)

### Phase 6: Linting + Constants (20-30s)
- **Semgrep constants enforcement** (backend/frontend/e2e)
- Ruff lint (Python)
- ESLint (TypeScript/React)
- Stylelint (CSS)
- **Bypass directive checking** (inline + file-level)

### Phase 7: Type Checking (30-50s)
- mypy strict (Python)
- tsc (TypeScript)
- type-coverage (100% frontend, 95% e2e)

### Phase 8: Complexity + Architecture (50-70s)
- Xenon complexity (Python)
- Import linting (Python)
- Dependency cruiser (React architecture)

### Phase 9: Framework-Specific (70-80s)
- Django system checks
- Django migrations validation
- Bandit security scan
- E2E credentials verification
- Migration-based fixtures enforcement

### Phase 10: Duplication (80-90s)
- jscpd (Frontend + E2E cross-duplication)
- E2E internal duplication

### Phase 11: Tests + Coverage (90-150s)
- TDD markers enforcement
- pytest with 90% coverage (backend)
- vitest with 90% coverage (frontend)

### Phase 12: Build Verification (150-180s)
- Vite production build

### Phase 13: E2E Tests (180-240s)
- Playwright test suite

## Exception Philosophy

⚠️ **Exceptions should be avoided at all costs** - they weaken quality enforcement and create blind spots.

### Core Principle
**Every exception must be justified. Adding exceptions is always the last possibility.**

Before adding ANY exception:
1. **Fix the root cause** - Refactor code, correct patterns, improve architecture
2. **Question the need** - Is this truly unavoidable or just inconvenient?
3. **Exhaust alternatives** - Have ALL other options been tried and failed?
4. **Document thoroughly** - Why is this exception absolutely necessary?

### Current Exceptions (ALL Justified)

**Constants directories** (`*/constants/*`):
- **Why**: Where constants are defined (literals expected by design)
- **Cannot avoid**: Constants must contain literal values

**Django migrations** (`migrations/`):
- **Why**: Auto-generated by Django framework
- **Cannot avoid**: Not user-controlled code

**Dependencies** (`.venv/`, `node_modules/`):
- **Why**: Third-party code, not part of project
- **Cannot avoid**: External dependencies

**Technical artifacts** (`__pycache__/`, `.pyc`):
- **Why**: Python bytecode, build artifacts
- **Cannot avoid**: Compiler-generated

**Application entry points** (`main.tsx`, `manage.py`):
- **Why**: Framework entry points with special export requirements
- **Cannot avoid**: Framework contract

**Dead code whitelists** (`vulture_whitelist.py`):
- **Why**: Intentionally list "unused" code that's dynamically referenced
- **Cannot avoid**: Dead code detector requires explicit whitelist

### Adding New Exceptions

If you believe you need an exception:

1. **Try everything else first**
   - Refactor the code
   - Fix the underlying issue
   - Adjust the approach
   - Reconsider the design

2. **If still blocked, ask yourself**:
   - Is this generated code I don't control?
   - Is this a framework requirement I cannot change?
   - Have I tried EVERY possible alternative?
   - Will this exception weaken the overall quality enforcement?

3. **Only then, document it**:
   - Add to appropriate whitelist/exclusion
   - Include detailed comment explaining WHY unavoidable
   - Reference the code or framework requirement
   - Note what alternatives were tried

### Finding Exceptions in Code

All exceptions are documented inline:
- **Semgrep rules**: `template/semgrep/*.yml` (path exclusions)
- **Pre-commit hooks**: `template/.pre-commit-config.yaml` (tool-specific exclusions)
- **Custom hooks**: `template/hooks/*.sh` (whitelist arrays)

Look for comments starting with:
- `JUSTIFIED EXCEPTIONS - DO NOT ADD MORE`
- `DO NOT ADD MORE EXCLUSIONS`
- `LAST RESORT ONLY`

## Key Features

### 1. Always-Run Strategy

Unlike typical pre-commit setups, fluxid guard uses `always_run: true` on critical checks to ensure:
- Security scans run on every commit (not just when secrets might be added)
- Dead code detection runs comprehensively (not just on changed files)
- Type checking validates entire codebase (not just modified files)
- Tests run with full coverage (preventing coverage degradation)

### 2. Smart Exclusions

#### Frontend (React/TypeScript)
- JSX attributes (`className`, `style`, `aria-*`) - **except test IDs**
- Test IDs (`data-testid`) - **enforced to use constants**
- TypeScript type literals
- i18n translation keys (`t("...")`)
- Test framework descriptions (`describe`, `it`, `test`)
- Console logging

#### Backend (Django/Python)
- Django ORM field parameters (`max_length`, `max_digits`)
- URL patterns (`path()`, `re_path()`)
- Model relationships (`related_name`)
- Migrations

#### E2E (Playwright)
- Playwright locators (`page.getByRole`, `page.locator`)
- Test framework setup (`test.describe`, `beforeEach`)
- Test descriptions

### 3. Constants Enforcement

Semgrep rules enforce constants usage while excluding framework patterns:

**Backend**:
```python
# ❌ Hardcoded values
return HttpResponse("Success", status=200)

# ✅ Constants
from constants import HTTP_STATUS_OK, SUCCESS_MESSAGE
return HttpResponse(SUCCESS_MESSAGE, status=HTTP_STATUS_OK)

# ✅ Framework patterns (excluded)
class User(models.Model):
    name = models.CharField(max_length=100)  # OK
```

**Frontend**:
```typescript
// ❌ Hardcoded values
const API_URL = "https://api.example.com";

// ✅ Constants
import { API_URL } from "@/constants";

// ✅ Framework patterns (excluded)
<Button className="btn-primary" />  // OK
describe("Button component", () => ...)  // OK
```

**Frontend Test IDs** (enforced separately):
```typescript
// ❌ Hardcoded test IDs
<Button data-testid="login-button">Login</Button>
screen.getByTestId("login-button")

// ✅ Test ID constants
// src/constants/testIds.ts
export const TEST_IDS = {
  LOGIN_BUTTON: "login-button",
  LOGOUT_BUTTON: "logout-button",
} as const;

// Component
import { TEST_IDS } from "@/constants/testIds";
<Button data-testid={TEST_IDS.LOGIN_BUTTON}>Login</Button>

// Test
import { TEST_IDS } from "@/constants/testIds";
screen.getByTestId(TEST_IDS.LOGIN_BUTTON)

// ✅ Dynamic test IDs (allowed)
<div data-testid={`user-${userId}-card`}>  // OK
```

**E2E**:
```typescript
// ❌ Hardcoded values
await page.fill("#username", "test@example.com");

// ✅ Constants
import { TEST_USER_EMAIL } from "@/constants";
await page.fill("#username", TEST_USER_EMAIL);

// ✅ Framework patterns (excluded)
await page.getByRole("button", { name: "Submit" });  // OK
```

### 4. Bypass Directive Enforcement

Prevents blanket error suppression that masks real issues:

**Inline Directives** (must specify error codes):
```python
# ❌ Blanket bypasses
result = eval(user_input)  # type: ignore
config = load_yaml(file)  # noqa
subprocess.run(cmd)  # nosec

# ✅ Specific bypasses
result = eval(user_input)  # type: ignore[arg-type]
config = load_yaml(file)  # noqa: S105
subprocess.run(cmd)  # nosec B603
```

**File-Level Directives** (blocked in regular code):
```python
# ❌ File-level blanket bypasses (blocked)
# mypy: ignore-errors
# pylint: skip-file
# flake8: noqa
# ruff: noqa

# ✅ Use specific inline directives instead
def process_data(value):
    return str(value)  # type: ignore[arg-type]

# ✅ Or specify error codes for file-level ruff
# ruff: noqa: F821, E501
```

**Whitelist Exceptions** (files that legitimately need blanket bypasses):
- `vulture_whitelist.py` - Dead code detector whitelist
- `*/constants/*` - Constants files may contain literals

To add a file to the whitelist, edit `.hooks/check-bypass-directives.sh`:
```bash
WHITELIST_FILES=(
  "vulture_whitelist.py"
  "*/constants/*"
  "*/generated/*"  # Example: generated code
)
```

## Common Commands

```bash
# Regular commit (fail-fast, default)
git commit -m "your message"

# Full audit (see all violations)
pre-commit run --all-files --config .pre-commit-config-full.yaml

# Run specific hook
pre-commit run backend-ruff-lint --all-files

# Skip specific hook (emergency only)
SKIP=backend-mypy git commit -m "wip"

# Update all hooks to latest versions
pre-commit autoupdate

# Manually run hooks without committing
pre-commit run --all-files

# Generate audit report
pre-commit run --all-files --config .pre-commit-config-full.yaml 2>&1 | tee quality-audit.txt
```

## Troubleshooting

### "pre-commit not found"

Install pre-commit:
```bash
pip install pre-commit
# or
brew install pre-commit
```

### "Hook failed: No such file or directory"

Ensure dependencies are installed:
```bash
# Backend
cd backend
python -m venv .venv
.venv/bin/pip install -r requirements-dev.txt

# Frontend
cd frontend
npm install

# E2E
cd e2e-tests
npm install
```

### "Expected directories not found"

Either:
1. Create the expected directories (`backend/`, `frontend/`, `e2e-tests/`)
2. Or use a custom config.yaml with your actual paths

### Hooks are too slow

This is normal for the first run. Subsequent runs are much faster due to:
- Pre-commit's file caching
- Tool-specific caches (.mypy_cache, node_modules/.cache)
- Git's change detection

Typical times:
- First run: 3-5 minutes
- Incremental runs: 10-30 seconds (only changed files)
- Full runs: 1-2 minutes (with caching)

## Development

### Project Structure

```
fluxid-guard/
├── install.sh                 # Main installation script
├── template/                  # Source templates
│   ├── .pre-commit-config.yaml    # With {{PLACEHOLDERS}}
│   ├── .gitleaks.toml
│   ├── .jscpdrc
│   ├── hooks/                 # Custom validation scripts
│   └── semgrep/               # Constants enforcement rules
└── examples/                  # Example configurations
    ├── config.yaml.default
    ├── config.yaml.custom
    └── config.yaml.monorepo
```

### Architecture

fluxid guard uses a simple template-based approach:

1. **Templates** contain placeholder variables: `{{BACKEND_DIR}}`, `{{FRONTEND_DIR}}`, `{{E2E_DIR}}`
2. **install.sh** performs simple `sed` substitution
3. **No complex merging** or version management required

### Updating Templates

To update the ruleset:

1. Edit `template/.pre-commit-config.yaml`
2. Use placeholders for paths: `{{BACKEND_DIR}}/`, `{{FRONTEND_DIR}}/`, `{{E2E_DIR}}/`
3. Test with install.sh
4. Commit changes

## Version History

### Latest (2026-01)
- **Complete rewrite**: Simplified architecture, removed component system
- **100% always-run coverage**: No more bypass holes
- **Split semgrep rules**: Separate numeric/string enforcement
- **Enhanced exclusions**: Smart framework-aware patterns
- **One-command install**: Simple curl | bash setup
- **Configuration-based**: YAML config instead of presets

### Archive
- **v3-legacy** (archive/v3-legacy branch): Component-based system with presets
- Earlier versions deprecated

## Credits

Based on battle-tested quality configurations from real-world production projects, particularly the p26f and word-trainer-simple codebases.

## License

MIT License - See LICENSE file for details.

## Contributing

Contributions welcome! This project prioritizes:
- Simplicity over flexibility
- Pre-commit native patterns
- Real-world proven configurations
- Breaking changes over backward compatibility

## Support

- **Issues**: https://github.com/steinmann321/fluxid-guard/issues
- **Discussions**: https://github.com/steinmann321/fluxid-guard/discussions
- **Archive (v3)**: https://github.com/steinmann321/fluxid-guard/tree/archive/v3-legacy
