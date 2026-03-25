container_name := "devcontainer-" + shell('cd .. && basename $(pwd)')
args := "--workspace-folder .. --docker-path /bin/podman"
shell := env_var_or_default("SHELL", "bash")

# List available recipes when no argument is provided
default:
    @just --list --justfile {{justfile()}}

build:
    devcontainer up {{args}}

up: build
    podman start {{container_name}}
    devcontainer exec {{args}} {{shell}}

stop:
    podman stop {{container_name}}

down:
    podman rm --force {{container_name}}
