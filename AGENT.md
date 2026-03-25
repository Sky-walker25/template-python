# Agent Configuration

## Project Overview
This is a [Copier](https://copier.readthedocs.io/) template for Python projects. It generates new Python projects with a standardized development environment.

## Technology Stack
- **Python**: 3.11
- **Package Manager**: [PDM](https://pdm.financierai.com/)
- **Linter/Formatter**: [Ruff](https://docs.astral.sh/ruff/)
- **Type Checker**: [Mypy](https://mypy-lang.org/)
- **Pre-commit Hooks**: [Pre-commit](https://pre-commit.com/)
- **Task Runner**: [Just](https://just.systems/)
- **Dev Environment**: Dev Containers

## Commands

### Development Setup
```bash
just setup  # Install dependencies, setup mypy types, and configure pre-commit hooks
```

### Code Quality
```bash
pdm run ruff check .          # Lint code
pdm run ruff format .        # Format code
pdm run mypy src/            # Type check
pdm run pre-commit run --all-files  # Run all pre-commit hooks
```

### Package Management
```bash
pdm sync --group :all        # Sync dependencies
pdm install --group :all     # Install dependencies
pdm venv activate            # Get venv activation command
```

## Code Style
- Follow PEP 8 conventions (enforced by Ruff)
- Use type hints for all function signatures
- Keep dependencies in `pyproject.toml` using `[dependency-groups]` for dev dependencies

## File Structure
```
template/
├── .devcontainer/     # Dev container configuration
├── .pre-commit-config.yaml  # Pre-commit hooks
├── justfile           # Just recipes
├── pdm.toml          # PDM configuration
├── pyproject.toml.jinja  # Project config template
├── recipes/          # Just recipe modules
│   ├── devcontainers.just
│   └── template.just
└── src/
    └── {{project_name}}/  # Package source (jinja template)
```

## Key Conventions
1. Python packages are located in `src/`
2. Mypy cache is stored in `/tmp/cache/mypy/`
3. Ruff cache is stored in `/tmp/cache/ruff/`
4. User-specific setup scripts go in `.devcontainer/setup.sh` (not versioned)
