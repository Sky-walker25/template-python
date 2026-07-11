set working-directory := ".."

container_name := "devcontainer-" + file_name(justfile_directory())
args := "--workspace-folder . --docker-path podman"
shell := "bash"

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
