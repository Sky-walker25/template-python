set working-directory := ".."

# List available recipes when no argument is provided
default:
    @just --list --justfile {{justfile()}}

# Setup a native development environment with uv (no devcontainer)
setup:
    uv sync --all-groups
    uv run pre-commit install
    -uv run pre-commit run --all-files
