# Instructions

This repository is a **Copier template** that generates standardized Python projects. The `template/` subdirectory is the actual template source; the root-level files configure and drive the template generation.

## Architecture

```
/
├── copier.yaml          # Template config: prompts, tasks, Jinja extensions
├── extensions.py        # Jinja ContextHook that injects git_user_name / git_user_email
├── cliff.toml           # git-cliff config for CHANGELOG generation (conventional commits)
├── template/            # Actual Copier template source
│   ├── .devcontainer/   # Dev container with Python 3.11, PDM, Just, Copier pre-installed
│   ├── .recipes/        # Just recipe modules copied into generated projects
│   ├── src/{{package_name}}/  # Generated package (src layout)
│   └── pyproject.toml.jinja   # Project metadata template
```

`copier.yaml` points at `template/` as the subdirectory, excludes `extensions.py` from output, and runs three post-copy Git tasks: `git init`, `git add .`, and the initial commit.

## Conventions

**Template files:** Jinja templates use the `.jinja` suffix (e.g. `pyproject.toml.jinja`, `README.md.jinja`). Directory names can also be Jinja expressions (e.g. `{{project_name}}/`).

**Copier variables:** `project_name`, `description`, `author_name`, `author_email`. Author fields default to values from `extensions.py:GitContext` (reads `git config user.name/email`).

**Commits:** Follow conventional commits — type(`feat:`, `fix:`, `chore:`, `test:`, etc) + optional scope + description starting with a verb (`add`, `remove`, `change`, `improve`, etc.).

**Cache paths:** All tool caches go under `/tmp/cache/<tool>/` (mypy, ruff, pytest) — never committed.

**Secrets:** `.env.local` and `.devcontainer/env.local` hold local secrets and are gitignored. `.devcontainer/setup.sh` (also gitignored) handles per-user container setup.

**Generated project src layout:** Packages live in `src/<package_name>/` and include a `py.typed` marker (PEP 561). Python version is pinned to `==3.11.*`.

**Type hints:** Required on all function signatures; checked by Mypy with `install-types` enabled.

## README is the source of truth
Treat README.md as the authoritative reference for the repository conventions, structure and workflow.
Before changing code, review the README sections relevant to your task.
Before finishing, check whether your changes conflict with documented conventions or commands.
If your change affects setup, structure, workflow, or commands described in the README, update the README in the same change.
If the README conflicts with code, tests, or other repo instructions, follow the more specific or more authoritative source and note the discrepancy.

## Commits
Follow conventional commits — type(feat:, fix:, chore:, test:, etc) + optional scope + description starting with a verb (add, remove, change, improve, etc.).

## Tooling
just recipes are for users only. Never invoke just recipes yourself.
