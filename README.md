# Python template

A pretty good dev container setup for python development.

## Features
- All python packages are installed in the container. They do not leak into the host file system.
- Tokens are made available for build time (access to gitlab).
- Environment is setup after the workspace is mounted on first build. This is used for installing requirements, setting-up mypy, pre-commits, etc.
    - Includes local, per-user setup script.

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
copier copy --trust https://gitlab.accenta.ai/accenta/recherche/template-python <PROJECT_NAME>
```

3. Launch dev container
Launch VS Code or run `just devcontainer:up` from your terminal.

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
The python environment is created in `/venv`. Mypy, Ruff and Pytest have their cache located in `/cache/<tool>` (set in `pyproject.toml`).
