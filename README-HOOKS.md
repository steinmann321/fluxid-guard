# AI-First Code Quality Enforcement System

A production-ready QA enforcement system specifically designed to maintain **enterprise-grade code quality** in AI-generated codebases. Tailored for Django backends, React frontends, and Playwright E2E testing, this system ensures AI-generated code meets rigorous professional standards through automated, comprehensive quality checks.

## Overview

**Built for AI-Generated Code**: As AI tools become integral to development workflows, maintaining code quality becomes critical. This system enforces strict quality gates that catch common AI-generated code issues including inconsistent patterns, security vulnerabilities, type safety violations, and architectural drift.

This system provides:
- **7 pre-commit hook scripts** with AI-code-aware enforcement across frontend, backend, and E2E tests
- **55+ enforcement rules** exceeding industry standards using best-in-class tools (Ruff, ESLint, Semgrep, Mypy, etc.)
- **Comprehensive configuration** for all QA tools (pre-commit, gitleaks, jscpd, semgrep)
- **Zero-tolerance policy** for security issues, type errors, and code smells
- **One-command installation** with intelligent project structure detection
- **Idempotent operation** - safe to run multiple times
- **Production-ready defaults** - no configuration needed to achieve high quality standards

## Quick Start

```bash
# Run the installer with target directory as argument
/path/to/qa-hooks/install-hooks.sh /path/to/your/project

# Or if you're in the qa-hooks directory:
./install-hooks.sh /path/to/your/project
```

The installer will:
1. Validate the target directory exists
2. Detect your project structure (backend/, frontend/, e2e-tests/)
3. Prompt for port configuration (defaults: Django 8000, Vite 5173)
4. Install all necessary QA tools and configurations
5. Set up pre-commit hooks
6. Validate the installation

## Requirements

### System Requirements
- **Git** - Project must be a git repository
- **Python 3.11+** - Required for backend QA tools
- **Node.js & npm** - Required for frontend/E2E QA tools

### Target Use Case
**AI-Generated Codebases**: This system is optimized for projects where AI tools (Claude, GitHub Copilot, ChatGPT, etc.) are used to generate significant portions of code. It enforces quality standards that ensure AI-generated code is:
- **Production-ready**: Meets professional deployment standards
- **Maintainable**: Consistent, well-structured, and documented
- **Secure**: Free from common vulnerabilities and security anti-patterns
- **Type-safe**: Fully typed with strict type checking
- **Architecturally sound**: Follows best practices and architectural patterns

### Supported Tech Stack
This system is designed for the modern full-stack web development pattern:
- **Backend**: Django web framework with Python 3.11+
- **Frontend**: React applications with TypeScript (JavaScript supported)
- **E2E Testing**: Playwright test framework
- **Quality Tools**: Pre-commit, Ruff, Mypy, ESLint, Semgrep, and more

### Project Structure
The installer expects (but can adapt to) the following structure:
```
project/
├── backend/          # Django project with manage.py
├── frontend/         # React project with package.json
└── e2e-tests/        # Playwright tests with package.json
```

The installer intelligently detects your project structure. If your folders have different names, it will automatically find them by searching for framework-specific files (manage.py, package.json with react, etc.).

## What Gets Installed

### Hook Scripts (.hooks/)
1. **shared-guard.sh** - Common quality checks across all code
2. **frontend-guard.sh** - Frontend-specific checks (ESLint, Prettier, Vitest)
3. **backend-guard.sh** - Backend-specific checks (Ruff, Mypy, Pytest)
4. **e2e-guard.sh** - E2E-specific checks (Playwright, accessibility)
5. **frontend-max-lines.sh** - Enforces file length limits in frontend
6. **backend-max-lines.sh** - Enforces file length limits in backend
7. **check-bypass-directives.sh** - Prevents disabling of quality checks

### Backend Tools (18 packages)
- **Linting & Formatting**: ruff
- **Type Checking**: mypy, django-stubs
- **Testing**: pytest, pytest-django, pytest-cov
- **Security**: bandit, pip-audit
- **Code Quality**: xenon, vulture, autoflake
- **Architecture**: import-linter
- **Static Analysis**: semgrep
- **Pre-commit**: pre-commit
- **Performance**: nplusone

### Frontend Tools (44 packages)
- **Linting**: ESLint with 10+ plugins
- **Formatting**: Prettier
- **Testing**: Vitest, Testing Library, jsdom
- **Type Checking**: TypeScript, type-coverage
- **Code Quality**: depcheck, dependency-cruiser, knip, ts-unused-exports
- **Style Linting**: stylelint
- **Duplication Detection**: jscpd
- **Build**: Vite

### E2E Tools (11 packages)
- **Testing**: Playwright
- **Accessibility**: @axe-core/playwright
- **Linting**: ESLint with Playwright plugin
- **Type Checking**: TypeScript, type-coverage

### Configuration Files
- `.pre-commit-config.yaml` - Pre-commit framework configuration
- `.gitleaks.toml` - Secret detection rules
- `.jscpdrc` - Code duplication detection config
- `.semgrep/base.yml` - Base semgrep rules
- `.semgrep/e2e.yml` - E2E-specific semgrep rules
- Backend: `pyproject.toml` updates (tool configurations)
- Frontend: Multiple config files (eslint, vite, vitest, prettier, etc.)
- E2E: Playwright and ESLint configurations

## Usage

### Installation
```bash
# Standard installation
./install-hooks.sh /path/to/target/project

# The script will prompt for confirmation before proceeding
```

**Port Configuration**

During installation, you'll be prompted to configure ports for your services:

```
Backend API port (Django default): 8000
  Use default port 8000? [Y/n]:

Frontend dev server port (Vite default): 5173
  Use default port 5173? [Y/n]:
```

- Press Enter or type `y` to use the default ports
- Type `n` to specify custom ports

The installer will automatically configure:
- `frontend/vite.config.ts` - Backend API proxy target
- `e2e-tests/playwright.config.ts` - Test server URLs and baseURL

This ensures the QA system works seamlessly with your project's port configuration.

### Re-installation
The script is idempotent and can be run multiple times:
```bash
# Re-run to update configurations
./install-hooks.sh /path/to/target/project
```

This will:
1. Backup existing hooks to `.hooks-backup-<timestamp>/`
2. Remove old hooks
3. Install fresh copies
4. Merge new configurations with existing ones

### Manual Hook Execution
You can run hooks manually without committing (from within the target project):

```bash
cd /path/to/target/project

# Run all hooks on all files
pre-commit run --all-files

# Run specific hook
pre-commit run ruff --all-files

# Run hooks on staged files only
pre-commit run
```

### Testing the Installation
```bash
cd /path/to/target/project

# Test backend
cd backend
source .venv/bin/activate
pytest
ruff check .
mypy .

# Test frontend
cd frontend
npm test
npm run lint
npm run typecheck

# Test E2E
cd e2e-tests
npm test
```

## Configuration Customization

### Backend (pyproject.toml)
The installer merges QA tool configurations into your existing `pyproject.toml`. You can customize:
- Ruff rules and line length
- Pytest markers and options
- Coverage thresholds
- Mypy strictness
- Vulture confidence levels

### Frontend (package.json + configs)
Frontend configurations are copied as separate files:
- `eslint.config.js` - ESLint rules
- `vite.config.ts` - Build configuration
- `vitest.config.ts` - Test configuration
- `.prettierrc.cjs` - Code formatting
- `stylelint.config.json` - CSS linting
- `dependency-cruiser.cjs` - Architecture rules

### E2E (playwright.config.ts)
E2E configurations include:
- Playwright browser settings
- Test execution options
- Accessibility testing with axe-core

## Enforcement Rules: Enterprise-Grade Standards

This system enforces **strict quality standards** designed to validate AI-generated code against professional production requirements.

### Backend (Python/Django) - Strict Type Safety & Security
- **Code Style**: 100 char line length, double quotes, LF line endings (Ruff with 24+ rule categories)
- **Type Safety**: Strict mypy with django-stubs - **no untyped code allowed**
- **Testing**: **90% coverage minimum** with TDD markers for test categorization
- **Security**: Bandit for security issues + pip-audit for dependency vulnerabilities - **zero tolerance**
- **Code Complexity**: Xenon cyclomatic complexity limits - prevents over-complex AI-generated functions
- **Dead Code**: Vulture detection - catches unused AI-generated code
- **Architecture**: Import-linter enforces layered architecture - prevents AI from creating circular dependencies
- **Code Quality**: Autoflake removes unused imports - common in AI-generated code
- **Performance**: N+1 query detection - catches inefficient database patterns

### Frontend (React/TypeScript) - Enterprise-Grade Standards
- **Code Style**: ESLint with 10+ specialized plugins + Prettier - enforces consistent patterns
- **Type Safety**: **Strict TypeScript** with type-coverage tracking - minimum type coverage enforced
- **Testing**: Vitest with coverage + accessibility testing (vitest-axe) - ensures inclusive UIs
- **Dependencies**: Zero unused dependencies (depcheck, knip, ts-unused-exports) - keeps codebase lean
- **Architecture**: Module boundaries enforced (dependency-cruiser) - prevents architectural drift
- **Code Duplication**: jscpd detection - catches copy-paste patterns common in AI code
- **Style Linting**: Stylelint for CSS - maintains consistent styling
- **Bundle Analysis**: Dependency analysis to prevent bloat

### E2E (Playwright) - Accessibility & Reliability First
- **Accessibility**: @axe-core/playwright automated WCAG compliance checks
- **Code Quality**: ESLint with Playwright-specific rules for test reliability
- **Type Safety**: TypeScript enforcement in test code
- **Best Practices**: Semgrep rules for E2E test patterns

### Shared (All Projects) - Zero-Compromise Security
- **Secrets Detection**: Gitleaks scans for hardcoded credentials - **blocks commits with secrets**
- **Security Analysis**: Semgrep static analysis with custom rules for the tech stack
- **Code Duplication**: jscpd across entire codebase - enforces DRY principle
- **Bypass Prevention**: Detects and blocks attempts to disable quality checks (eslint-disable, type: ignore, etc.)
- **Commit Quality**: Pre-commit framework orchestrates all checks - **nothing gets through**

### Why Enterprise-Grade Standards?

**Many projects** compromise on:
- Type errors in "low-risk" areas
- Coverage below 80%
- Some code duplication
- Skipping accessibility checks
- Manual security reviews

**This system enforces**:
- **100% type safety** - no untyped code
- **90% coverage minimum** - comprehensive test coverage
- **Zero duplication** - DRY principle strictly enforced
- **Automated accessibility** - WCAG compliance built-in
- **Automated security** - continuous vulnerability scanning
- **No bypass allowed** - quality checks cannot be disabled

This rigorous approach ensures AI-generated code meets professional production standards.

## Common AI-Generated Code Issues This System Catches

AI tools are powerful but can generate code with subtle quality issues. This system automatically detects and blocks:

### Type Safety Issues
- **Missing type annotations**: AI often generates untyped Python or `any` types in TypeScript
- **Incorrect type assumptions**: AI may infer wrong types based on context
- **Type narrowing failures**: Generic types where specific types are needed

### Security Vulnerabilities
- **Hardcoded credentials**: AI may include example API keys or passwords in code
- **SQL injection patterns**: String concatenation in database queries
- **XSS vulnerabilities**: Unescaped user input in templates
- **Insecure dependencies**: AI may suggest outdated packages with known CVEs

### Architectural Problems
- **Circular imports**: AI doesn't track the full dependency graph
- **Layer violations**: Business logic in presentation layer, etc.
- **God objects**: AI tends to add too much functionality to single classes
- **Tight coupling**: AI-generated code often lacks proper abstraction

### Code Quality Issues
- **Unused imports**: AI frequently imports more than needed
- **Dead code**: Unreachable code or unused variables
- **Code duplication**: AI may regenerate similar code instead of reusing
- **High complexity**: Over-complicated solutions to simple problems
- **N+1 queries**: Inefficient database access patterns

### Testing Gaps
- **Low coverage**: AI-generated code without corresponding tests
- **Missing edge cases**: Tests only for happy paths
- **Accessibility violations**: UI components not meeting WCAG standards
- **Flaky tests**: Race conditions and timing issues

### Maintenance Issues
- **Inconsistent patterns**: AI uses different approaches for similar problems
- **Missing documentation**: Code without docstrings or comments
- **Non-standard naming**: Inconsistent variable/function naming conventions
- **Formatting inconsistencies**: Mixed indentation, line lengths, etc.

**With this system**: All these issues are **automatically detected and blocked** before they enter your codebase, ensuring AI-generated code maintains production quality standards.

## Troubleshooting

### Installation Fails - Python Not Found
```bash
# Install Python 3.11+
brew install python@3.11  # macOS
sudo apt install python3.11  # Ubuntu
```

### Installation Fails - npm Not Found
```bash
# Install Node.js and npm
brew install node  # macOS
sudo apt install nodejs npm  # Ubuntu
```

### Pre-commit Hooks Not Running
```bash
# Reinstall hooks
pre-commit install

# Verify installation
pre-commit run --all-files
```

### Backend Tests Failing
```bash
# Ensure virtual environment is activated
cd backend
source .venv/bin/activate

# Update dependencies
pip install -r requirements.txt
pip install -r .hook-templates/backend-configs/requirements-qa.txt
```

### Frontend Build Failing
```bash
# Reinstall dependencies
cd frontend
rm -rf node_modules package-lock.json
npm install
```

### Merge Conflicts in Configuration Files
The installer creates backups in `.hooks-backup-<timestamp>/`. You can:
1. Review the backup files
2. Manually merge any custom configurations
3. Re-run the installer

## Uninstallation

To remove all hooks and configurations from a target project:

```bash
cd /path/to/target/project

# Remove hooks and configs
rm -rf .hooks
rm -f .pre-commit-config.yaml .gitleaks.toml .jscpdrc
rm -rf .semgrep

# Uninstall pre-commit hooks
pre-commit uninstall

# Remove QA tools (optional)
# Backend
cd backend
pip uninstall -y $(pip freeze | grep -E "ruff|mypy|pytest|bandit|semgrep|vulture|xenon|autoflake|import-linter|nplusone")

# Frontend
cd frontend
npm uninstall eslint prettier vitest typescript stylelint jscpd depcheck dependency-cruiser knip

# E2E
cd e2e-tests
npm uninstall @playwright/test @axe-core/playwright
```

## Directory Structure

```
qa-hooks/
├── install-hooks.sh              # Main installer script
├── merge-config.py               # Configuration merger utility
├── README-HOOKS.md               # This file
│
└── .hook-templates/              # Template library
    ├── hooks/                    # 7 hook scripts
    │   ├── shared-guard.sh
    │   ├── frontend-guard.sh
    │   ├── backend-guard.sh
    │   ├── e2e-guard.sh
    │   ├── frontend-max-lines.sh
    │   ├── backend-max-lines.sh
    │   └── check-bypass-directives.sh
    │
    ├── configs/                  # Shared configs
    │   ├── .pre-commit-config.yaml
    │   ├── .gitleaks.toml
    │   ├── .jscpdrc
    │   ├── semgrep-base.yml
    │   └── semgrep-e2e.yml
    │
    ├── backend-configs/          # Backend-specific
    │   ├── requirements-qa.txt
    │   └── pyproject-additions.toml
    │
    ├── frontend-configs/         # Frontend-specific
    │   ├── package-additions.json
    │   ├── eslint.config.js
    │   ├── vite.config.ts
    │   ├── vitest.config.ts
    │   ├── tsconfig*.json
    │   ├── dependency-cruiser.cjs
    │   ├── stylelint.config.json
    │   └── prettierrc.cjs
    │
    └── e2e-configs/              # E2E-specific
        ├── package-additions.json
        ├── eslint.config.js
        ├── playwright.config.ts
        └── tsconfig-additions.json
```

## Advanced Usage

### Custom Folder Names
The installer automatically detects standard folder names (backend/, frontend/, e2e-tests/). If your project uses different names, the installer will attempt to auto-detect them by searching for:
- Django projects (manage.py)
- React projects (package.json with "react" dependency)
- Playwright projects (package.json with "@playwright/test")

### Selective Installation
You can modify `install-hooks.sh` to skip certain setups:

```bash
# In main() function, comment out unwanted setups:
# [[ -n "$FRONTEND_DIR" ]] && setup_frontend_qa  # Skip frontend
```

### CI/CD Integration
Use the installer in CI/CD pipelines:

```bash
# In your CI/CD script
/path/to/qa-hooks/install-hooks.sh "$CI_PROJECT_DIR"
cd "$CI_PROJECT_DIR"
pre-commit run --all-files

# Or run specific checks
cd backend && pytest
cd frontend && npm test
cd e2e-tests && npm test
```

## Philosophy: Quality Gates for AI-Generated Code

As AI becomes central to software development, the need for robust quality enforcement grows exponentially. This system embodies the principle that **AI-generated code should meet or exceed the standards of human-written code**.

### Key Principles
1. **Trust but Verify**: AI is a powerful tool, but automated verification ensures quality
2. **Prevention over Correction**: Catch issues before they enter the codebase
3. **Consistency**: AI output varies; enforcement ensures uniform quality
4. **Security First**: Zero-tolerance for security vulnerabilities
5. **Maintainability**: Code that's easy to understand and modify
6. **Professional Standards**: Production-ready code on every commit

### Best Practices for AI-Assisted Development
- **Review AI suggestions**: Don't blindly accept generated code
- **Run checks frequently**: Test early and often during development
- **Address issues immediately**: Don't accumulate technical debt
- **Learn from failures**: Understand why the QA system blocks code
- **Iterate**: Use AI to fix issues found by the QA system
- **Maintain standards**: Never disable quality checks to "get things done"

## License

This tool is provided for teams building AI-generated codebases that require enterprise-grade quality enforcement.

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review the hook scripts in `.hooks/` for specific errors
3. Check pre-commit logs: `.git/hooks/pre-commit.log`
4. Examine the installation logs for any error messages
5. Review the "Common AI-Generated Code Issues" section for understanding why code was blocked

## Version History

- **v1.0.0** - Initial release: AI-First Code Quality Enforcement System for Django + React + Playwright
  - 55+ enterprise-grade enforcement rules
  - Zero-tolerance security and type safety
  - Automated accessibility testing
  - Comprehensive documentation for AI-generated codebases
