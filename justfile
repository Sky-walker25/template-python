mod devcontainers '.recipes/devcontainers.just'
mod release '.recipes/release.just'

# List available recipes when no argument is provided
default:
    @just --list --justfile {{justfile()}}

# Setup the development environment
setup:
    # Source local setup script
    [ -f .devcontainer/setup.sh ] && .devcontainer/setup.sh || true
