# Copilot Instructions

## README is the source of truth

`README.md` describes the project structure, conventions, and workflow. It is
the authoritative reference for any task performed in this repository.

### Before starting a task
Read `README.md` in full. Understand the project layout, tooling, and any rules
that apply to the area you are about to change.

### Before finishing a task
Re-read `README.md` and verify your changes have not diverged from the rules and
conventions described there (architecture, tooling, naming, workflow, etc.).

### Keeping the README up to date
If your changes make any part of `README.md` inaccurate or incomplete (new
commands, changed structure, updated conventions, …), update the README as part
of the same task. The README must always reflect the actual state of the project.

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
│   ├── src/{{project_name}}/  # Generated package (src layout)
│   └── pyproject.toml.jinja   # Project metadata template
```

`copier.yaml` points at `template/` as the subdirectory, excludes `extensions.py` from output, and runs three post-copy tasks: `git init`, initial commit, and copying `.env` → `.env.local`.

## Conventions

**Template files:** Jinja templates use the `.jinja` suffix (e.g. `pyproject.toml.jinja`, `README.md.jinja`). Directory names can also be Jinja expressions (e.g. `{{project_name}}/`).

**Copier variables:** `project_name`, `description`, `author_name`, `author_email`. Author fields default to values from `extensions.py:GitContext` (reads `git config user.name/email`).

**Commits:** Follow conventional commits — type(`feat:`, `fix:`, `chore:`, `test:`, etc) + optional scope + description starting with a verb (`add`, `remove`, `change`, `improve`, etc.).

**Co-authoring:** When adding a `Co-authored-by` trailer for Copilot, use `Co-authored-by: Copilot <Copilot@users.noreply.github.com>` — no numeric ID in the address.

**Cache paths:** All tool caches go under `/tmp/cache/<tool>/` (mypy, ruff, pytest) — never committed.

**Secrets:** `.env.local` and `.devcontainer/env.local` hold local secrets and are gitignored. `.devcontainer/setup.sh` (also gitignored) handles per-user container setup.

**Generated project src layout:** Packages live in `src/<project_name>/` and include a `py.typed` marker (PEP 561). Python version is pinned to `==3.11.*`.

**Type hints:** Required on all function signatures; checked by Mypy with `install-types` enabled.

## Tooling

**`just` recipes are for users only.** Never invoke `just` recipes yourself.
