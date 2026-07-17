set working-directory := ".."

# List available recipes when no argument is provided
default:
    @just --list --justfile {{justfile()}}

up:
    devpod up --ide none .
    devpod ssh .

stop:
    devpod stop .

down:
    devpod delete .
