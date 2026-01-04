# fluxid qa - Modular Code Quality Enforcement System

A modular, component-based QA enforcement system for multiple tech stacks. Designed for AI-generated codebases with strict anti-cheating directives for LLMs.

## Supported Tech Stacks

### Backend
- **Django** - Python/Django with mypy strict, ruff, pytest, bandit
- **Go** - golangci-lint, gosec, 90% coverage, strict formatting

### Frontend
- **React** - TypeScript, ESLint, 100% type coverage, Vite, Vitest

### E2E Testing
- **Playwright** - Anti-flakiness rules, strict locator patterns

### Shared (All Stacks)
- Gitleaks (secrets detection)
- Semgrep (security & bug patterns)
- Code duplication detection
- Bypass directive enforcement

## Quick Start

### Auto-Detection (Recommended)
```bash
./install.sh /path/to/your/project
```

### Using Presets
```bash
# Django + React + Playwright
./install.sh /path/to/project --preset django-react-playwright

# Django only
./install.sh /path/to/project --preset django-only

# Go only
./install.sh /path/to/project --preset go-only
```

### Manual Component Selection
```bash
./install.sh /path/to/project --components backend/go,shared
```

### List Available Options
```bash
./install.sh --list-presets
./install.sh --list-components
```

## Project Structure

```
fluxid-qa/
├── components/              # Modular QA components
│   ├── backend/
│   │   ├── django/         # Django/Python QA
│   │   │   ├── component.json
│   │   │   ├── configs/
│   │   │   └── hooks/
│   │   └── go/             # Go QA
│   │       ├── component.json
│   │       ├── configs/
│   │       └── hooks/
│   ├── frontend/
│   │   └── react/          # React/TypeScript QA
│   │       ├── component.json
│   │       ├── configs/
│   │       └── hooks/
│   ├── e2e/
│   │   └── playwright/     # Playwright E2E QA
│   │       ├── component.json
│   │       ├── configs/
│   │       └── hooks/
│   └── shared/             # Universal checks
│       ├── component.json
│       ├── configs/
│       └── hooks/
├── lib/                    # Installer modules
│   ├── logging.sh
│   ├── component.sh
│   ├── validation.sh
│   ├── config.sh
│   ├── install.sh
│   └── main.sh
├── presets/                # Pre-configured stacks
│   ├── django-react-playwright.json
│   ├── django-only.json
│   └── go-only.json
├── tests/                  # Test suite
│   ├── unit/
│   ├── integration/
│   └── e2e/
└── install.sh              # Entry point
```

## Features

### Modular Architecture
- **Component-based**: Each tech stack is a self-contained component
- **Composable**: Mix and match components for your stack
- **Extensible**: Add new tech stacks by creating new components
- **Auto-detection**: Automatically detects your project structure
- **Preset system**: Pre-configured for common stacks

### Strict Quality Enforcement
- **55+ quality rules** across all components
- **Zero-tolerance** for security issues
- **90%+ test coverage** requirements
- **100% type coverage** for TypeScript
- **Max file line limits** (400 prod, 600 tests)
- **Anti-bypass directives** for LLMs

### LLM-Optimized Error Messages
All error messages are designed to prevent AI agents from cheating:
- Explicit **MANDATORY** and **NEVER** directives
- Clear decision hierarchies (FIRST/SECOND steps)
- Warning against common bypass tactics
- Documented justification requirements for exceptions

## Testing

The project includes a comprehensive test suite with 50+ tests:

```bash
# Run all tests
./tests/run_tests.sh

# Run specific test suites
bats tests/unit/         # Fast unit tests
bats tests/integration/  # Integration tests
bats tests/e2e/          # Full workflow tests
```

See [tests/README.md](tests/README.md) for detailed testing documentation.

## Adding New Tech Stacks

To add support for a new tech stack (e.g., Vue, FastAPI, Cypress):

1. **Create component directory**:
   ```bash
   mkdir -p components/frontend/vue/{configs,hooks}
   ```

2. **Create `component.json`**:
   ```json
   {
     "name": "vue",
     "type": "frontend",
     "display_name": "Vue Frontend",
     "detection": {
       "files": ["frontend/package.json"],
       "package_indicators": {
         "file": "frontend/package.json",
         "contains": "vue"
       }
     },
     "dependencies": {
       "system": ["node", "npm"],
       "components": ["shared"]
     },
     "hooks": ["hooks/vue-guard.sh"],
     "variables": {}
   }
   ```

3. **Create hooks** in `hooks/`:
   - `vue-guard.sh` - Main QA checks
   - `vue-max-lines.sh` - Line limit enforcement

4. **Add configs** in `configs/`:
   - ESLint, TypeScript, test configs, etc.

5. **Create preset** (optional):
   ```json
   {
     "name": "django-vue-playwright",
     "components": ["shared", "backend/django", "frontend/vue", "e2e/playwright"]
   }
   ```

6. **Test**:
   ```bash
   ./install.sh /path/to/project --components frontend/vue,shared
   ```

## Requirements

- **Git** - Project must be a git repository
- **jq** - JSON parsing (install: `brew install jq` / `apt install jq`)
- **Python 3.11+** - For Django/Python components
- **Go 1.21+** - For Go components
- **Node.js 18+** - For frontend/E2E components

## How It Works

1. **Detection**: Scans target project for tech stack indicators
2. **Validation**: Checks system dependencies for selected components
3. **Configuration**: Prompts for ports and other variables
4. **Installation**:
   - Copies hook scripts (read-only for security)
   - Copies/merges config files
   - Installs QA tools (venv for Python, go install for Go, npm for Node)
5. **Pre-commit setup**: Installs pre-commit framework

## Detailed Documentation

See [README-HOOKS.md](./README-HOOKS.md) for:
- Complete enforcement rules list
- Tool-by-tool breakdown
- Bypass directive philosophy
- Troubleshooting guide
- Uninstallation instructions

## Design Philosophy

### For AI-Generated Code
This system is built specifically for codebases where LLMs generate significant code:
- **Strict by default**: No configuration needed for high standards
- **Anti-cheating**: Error messages prevent LLMs from bypassing checks
- **Comprehensive**: Covers security, types, tests, architecture, duplication
- **Fail-fast**: Issues caught immediately, not in production

### For Human Developers
- **Clear errors**: Know exactly what to fix and why
- **Fast feedback**: Most checks complete in seconds
- **Modular**: Only install what you need
- **Documented**: Every rule has a clear purpose

## CI/CD Integration

Tests run automatically on GitHub Actions:
- Push to main/develop branches
- Pull requests

See `.github/workflows/test.yml` for configuration.

## License

MIT

## Contributing

To add new components:
1. Follow the component structure above
2. Use LLM-optimized error messages
3. Write tests (see tests/README.md)
4. Test with actual projects
5. Submit PR with preset examples

## Support

For issues or questions, open a GitHub issue at https://github.com/steinmann321/fluxid-qa
