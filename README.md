# Python template

A pretty good dev container setup for python development. Check the [rendered template](https://git.zagouri.org/templates/python-demo) to see it in action.

## Features
- **Containerized development** — all Python packages are installed inside the dev container and do not leak into the host file system. The environment is initialized on first build (dependencies, mypy, pre-commit hooks). Includes a local, per-user setup script. Secrets are available separately for build time and runtime.
- **Code quality tools** — linter (`ruff`), formatter (`black`, `isort`), type checker (`mypy`), and Git hooks (`pre-commit`).
- **PEP-compliant** — follows PEP 8 (style), PEP 621 (`pyproject.toml`), PEP 735 (dependency groups), PEP 751 (`pylock.toml`), and more.
- **Template updates** — generated projects can be updated to track new releases of this template.

### Template variables

| Variable | Description | Default |
|---|---|---|
| `project_name` | Human-readable project display name | Copier's `destination_path` |
| `package_name` | Python package identifier (auto-sanitized) | `project_name` lowercased, non-alphanumeric → `_` |
| `description` | Short project description | — |
| `author_name` | Author full name | `git config user.name` |
| `author_email` | Author e-mail address | `git config user.email` |

## Usage
1. Install `copier` and `git`.

[`copier`](https://copier.readthedocs.io/en/latest/) is a CLI app for rendering
project templates. I recommend installing it via `pipx`, although any tool
should work.

```bash
pipx install copier
pipx inject copier copier-template-extensions
```

2. Create a project from the template. Run:

```bash
copier copy --trust git@gitlab.accenta.ai:accenta/recherche/template-python.git <PROJECT_NAME>
```

Windows users must explicitly copy from the `windows` branch:

```bash
copier copy --trust --vcs-ref=windows git@gitlab.accenta.ai:accenta/recherche/template-python.git <PROJECT_NAME>
```

Copier runs three post-copy Git tasks: `git init`, `git add .`, and an initial
commit.

To adapt an existing project to the template, run:

```bash
copier copy --trust --skip-tasks git@gitlab.accenta.ai:accenta/recherche/template-python.git .
```

On Windows, also add `--vcs-ref=windows`:

```bash
copier copy --trust --skip-tasks --vcs-ref=windows git@gitlab.accenta.ai:accenta/recherche/template-python.git .
```

Optionally, add `--vcs-ref=HEAD` to the `copier copy` command to use the latest
commit from the repo, instead of the latest release (default). Windows users
should use `--vcs-ref=windows` instead.

3. Launch dev container

Launch VS Code or run `just devcontainers::up` from your terminal (executes the current `$SHELL` or fallback to `bash`).

### Per user setup
Some user have their own favorite configurations and tools. For this, the
`setup` just recipe includes executing the `.devcontainer/setup.sh` script if
it exists. This script is not versioned so that each user may edit it freely.

### Container management
VS Code handles most container related tasks: building, mounting essentials configurations, executing commands, etc. For standalone container management outside VS Code, a `devcontainers.just` module contains a few useful recipes. The container name is defined for both method as the equivalent of `"devcontainer-${basename $pwd}"`.

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
| [Ruff](https://docs.astral.sh/ruff/) | Linting |
| [Black](https://black.readthedocs.io/en/stable/) | Formatter |
| [Mypy](https://mypy.readthedocs.io/) | Static type checking (`install-types` enabled) |
| [pre-commit](https://pre-commit.com/) | Git hooks that run Ruff and common checks on commit |

All three are installed as dev dependencies and configured in `pyproject.toml`.

## Development
### Repository layout

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
