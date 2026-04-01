mod devcontainers '.recipes/devcontainers.just'
mod release '.recipes/release.just'

# List available recipes when no argument is provided
default:
    @just --list --justfile {{justfile()}}

# Setup the development environment
setup:
    # Setup pre-commit hooks
    pre-commit install
    pre-commit run --all-files || true
    # Source local setup script
    [ -f .devcontainer/setup.sh ] && .devcontainer/setup.sh || true
