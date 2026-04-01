# Copilot Instructions

This repository is a **Copier template** that generates standardized Python projects. The `template/` subdirectory is the actual template source; the root-level files configure and drive the template generation.

## Commands

All commands use `pdm` for Python tooling and `just` for task orchestration.

```bash
# Lint and format
pdm run ruff check .
pdm run ruff format .
pdm run mypy src/

# Run all pre-commit hooks
pdm run pre-commit run --all-files

# Install/sync dependencies
pdm sync --group :all

# Dev container lifecycle
just devcontainer::build
just devcontainer::up
just devcontainer::stop
just devcontainer::down

# Release management
just release::check   # preview unreleased commits
just release::release # draft a new release
just release::push    # push commits and tags
```

Just recipes are modularized under `.recipes/` and invoked as `just module::recipe`.

## Architecture

```
/
├── copier.yaml          # Template config: prompts, tasks, Jinja extensions
├── extensions.py        # Jinja ContextHook that injects git_user_name / git_user_email
├── cliff.toml           # git-cliff config for CHANGELOG generation (conventional commits)
├── template/            # Actual Copier template source
│   ├── .devcontainer/   # Dev container with Python 3.11, PDM, Just, Copier pre-installed
│   ├── .recipes/        # Just recipe modules copied into generated projects
│   ├── src/{{project_name}}/  # Generated package (src layout)
│   └── pyproject.toml.jinja   # Project metadata template
```

`copier.yaml` points at `template/` as the subdirectory, excludes `extensions.py` from output, and runs three post-copy tasks: `git init`, initial commit, and copying `.env` → `.env.local`.

## Conventions

**Template files:** Jinja templates use the `.jinja` suffix (e.g. `pyproject.toml.jinja`, `README.md.jinja`). Directory names can also be Jinja expressions (e.g. `{{project_name}}/`).

**Copier variables:** `project_name`, `description`, `author_name`, `author_email`. Author fields default to values from `extensions.py:GitContext` (reads `git config user.name/email`).

**Commits:** Follow conventional commits — `feat:`, `fix:`, `chore:`, `test:`, etc. git-cliff groups these into CHANGELOG sections. Release commits are formatted `chore(repo): release X.Y.Z`.

**Cache paths:** All tool caches go under `/tmp/cache/<tool>/` (mypy, ruff, pytest) — never committed.

**Secrets:** `.env.local` and `.devcontainer/env.local` hold local secrets and are gitignored. `.devcontainer/setup.sh` (also gitignored) handles per-user container setup.

**Generated project src layout:** Packages live in `src/<project_name>/` and include a `py.typed` marker (PEP 561). Python version is pinned to `==3.11.*`.

**Type hints:** Required on all function signatures; checked by Mypy with `install-types` enabled.
