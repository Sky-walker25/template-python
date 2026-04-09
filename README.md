# Python template

A pretty good dev container setup for python development.

## Features
- All python packages are installed in the container. They do not leak into the host file system.
- Tokens are made available for build time (access to gitlab).
- Environment is setup after the workspace is mounted on first build. This is used for installing requirements, setting-up mypy, pre-commits, etc.
    - Includes local, per-user setup script.

## Repository layout

```
├── copier.yaml          # Template config: prompts, tasks, Jinja extensions
├── extensions.py        # Jinja ContextHook — injects git_user_name / git_user_email
├── cliff.toml           # git-cliff config for CHANGELOG generation (conventional commits)
├── template/            # Actual Copier template source
│   ├── .devcontainer/   # Dev container definition (Containerfile, devcontainer.json)
│   ├── .recipes/        # Just recipe modules copied into generated projects
│   │   ├── devcontainers.just
│   │   ├── release.just.jinja
│   │   └── template.just
│   ├── src/{{package_name}}/  # Generated package (src layout)
│   └── pyproject.toml.jinja   # Project metadata template
```

### Copier variables

| Variable | Description | Default |
|---|---|---|
| `project_name` | Human-readable project display name | Copier's `destination_path` |
| `package_name` | Python package identifier (auto-sanitized) | `project_name` lowercased, non-alphanumeric → `_` |
| `description` | Short project description | — |
| `author_name` | Author full name | `git config user.name` |
| `author_email` | Author e-mail address | `git config user.email` |

## Setup
1. Install `copier`

[`copier`](https://copier.readthedocs.io/en/latest/) is a CLI app for rendering
project templates. I recommend installing it via `pipx`, although any tool
should work.

```bash
pipx install copier
pipx inject copier copier-template-extensions
```

2. Create a project from the template

Run:

```bash
copier copy --trust git@gitlab.accenta.ai:accenta/recherche/template-python.git <PROJECT_NAME>
```

Copier runs three post-copy tasks: `git init`, an initial commit, and copying
`.env` → `.env.local`.

3. Launch dev container

Launch VS Code or run `just devcontainers::up` from your terminal.

### Per user setup
Some user have their own favorite configurations and tools. For this, the
`setup` just recipe includes executing the `.devcontainer/setup.sh` script if
it exists. This script is not versioned so that each user may edit it freely.

## Shell
When launched through the `devcontainer` CLI, the container executes the shell currently used in the host, as indicated by the `$SHELL` environment variable (fallback to `bash`).


## Container management
When using VS Code, it handles most container related tasks: building, mounting essentials configurations, executing commands, etc. Outside, a `devcontainers.just` module contains most useful recipes.

### Container
The container name is defined in both `devcontainer.json` and `devcontainers.just` as the equivalent of `"devcontainer-${basename $pwd}"`.

## Python
The python environment is created in `/venv`. Mypy, Ruff and Pytest have their cache located in `/tmp/cache/<tool>/` (set in `pyproject.toml`).

### Package manager — PDM

Generated projects use [PDM](https://pdm-project.org/) to manage dependencies and the
virtual environment. The venv is created at `/venv` inside the container.

```bash
pdm add <package>          # add a runtime dependency
pdm add -dG dev <package>  # add a dev dependency
pdm sync --group :all      # install / sync all groups
```

### Code quality

| Tool | Purpose |
|---|---|
| [Ruff](https://docs.astral.sh/ruff/) | Linting and formatting |
| [Mypy](https://mypy.readthedocs.io/) | Static type checking (`install-types` enabled) |
| [pre-commit](https://pre-commit.com/) | Git hooks that run Ruff and common checks on commit |

All three are installed as dev dependencies and configured in `pyproject.toml`.
Type hints are required on all function signatures.
