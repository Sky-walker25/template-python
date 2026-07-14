#!/usr/bin/env bash
# Host bootstrap for the Python dev-container template - Linux.
#
# Verifies (and installs when missing) what you need to use the template with
# Podman + VS Code, or the CLI/Neovim flow. Idempotent: re-running only fixes
# what is missing. Podman runs natively on Linux, so there is no VM to manage.
#
# Usage:
#   ./bootstrap.sh          interactive
#   ./bootstrap.sh --yes    non-interactive (defaults, no prompts)
#   ./bootstrap.sh --check  report only, change nothing
set -euo pipefail

TEMPLATE_URL="git@gitlab.accenta.ai:accenta/recherche/template-python.git"
SSH_KEY="$HOME/.ssh/id_ed25519"
INTERACTIVE=1
CHECK=0

usage() { awk 'NR==1{next} /^#/{sub(/^# ?/,""); print; next} {exit}' "$0"; }

for arg in "$@"; do
  case "$arg" in
    --yes|-y)  INTERACTIVE=0 ;;
    --check)   CHECK=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; usage; exit 2 ;;
  esac
done

# ---- output helpers -------------------------------------------------------
if [ -t 1 ]; then
  BOLD=$'\033[1m'; DIM=$'\033[2m'; RED=$'\033[31m'; GRN=$'\033[32m'; YLW=$'\033[33m'; CYN=$'\033[36m'; RST=$'\033[0m'
else BOLD=; DIM=; RED=; GRN=; YLW=; CYN=; RST=; fi
info() { printf '%s->%s %s\n' "$CYN" "$RST" "$*"; }
ok()   { printf '%sOK%s %s\n' "$GRN" "$RST" "$*"; }
warn() { printf '%s !%s %s\n' "$YLW" "$RST" "$*"; }
err()  { printf '%s x%s %s\n' "$RED" "$RST" "$*"; }
hr()   { printf '%s\n' "${DIM}------------------------------------------------------${RST}"; }
have() { command -v "$1" >/dev/null 2>&1; }

# Install a package with whatever package manager the distro ships (needs sudo).
pkg_install() {
  info "Installing $1 (needs sudo)..."
  if   have apt-get; then sudo apt-get update -qq && sudo apt-get install -y "$1"
  elif have dnf;     then sudo dnf install -y "$1"
  elif have pacman;  then sudo pacman -S --noconfirm "$1"
  elif have zypper;  then sudo zypper install -y "$1"
  else err "No known package manager - install $1 manually, then re-run."; return 1; fi
}

# ---- doctor ---------------------------------------------------------------
doctor() {
  hr; printf '%sDoctor - current state%s\n' "$BOLD" "$RST"; hr
  if have podman; then ok "Podman: $(podman --version 2>/dev/null)"; else warn "Podman: not found (will install)"; fi
  if have git;    then ok "git: present"; else warn "git: not found (will install)"; fi
  if have copier; then ok "Copier: present"; else warn "Copier: missing (will install)"; fi
  if [ -f "$SSH_KEY" ]; then ok "SSH key: $SSH_KEY"; else warn "SSH key: none (will generate)"; fi
  hr
}

# ---- actions --------------------------------------------------------------
ensure_podman() {
  have podman || pkg_install podman || { warn "Could not install podman - install it manually, then re-run."; return 0; }
  if podman info >/dev/null 2>&1; then ok "Podman rootless OK"
  else warn "Podman is installed but rootless is not functional - check 'podman info'."; fi
}

ensure_git() {
  if have git; then ok "git present"; return; fi
  if pkg_install git; then ok "git installed"; else warn "Could not install git - install it manually, then re-run."; fi
}

ensure_copier() {
  if have copier; then ok "Copier already installed"; return; fi
  if ! have uv && ! have pipx; then
    have curl || pkg_install curl || true
    info "Installing uv to bootstrap Copier..."
    curl -LsSf https://astral.sh/uv/install.sh | sh || warn "uv installer exited non-zero"
    export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"; hash -r 2>/dev/null || true
  fi
  if have uv; then
    if uv tool install copier --with copier-template-extensions; then
      uv tool update-shell 2>/dev/null || true; ok "Copier installed"
    else warn "uv could not install Copier."; fi
  elif have pipx; then
    if pipx install copier && pipx inject copier copier-template-extensions; then ok "Copier installed"
    else warn "pipx could not install Copier."; fi
  else
    warn "Could not bootstrap Copier - install uv or pipx, then re-run."
  fi
}

ensure_git_identity() {
  if [ -z "$(git config --global core.editor || true)" ] && have code; then
    git config --global core.editor "code --wait"; ok "git editor: VS Code"
  fi
  local name email
  name="$(git config --global user.name  || true)"
  email="$(git config --global user.email || true)"
  if [ -n "$name" ] && [ -n "$email" ]; then ok "git identity: $name <$email>"; return; fi
  if [ "$INTERACTIVE" -eq 0 ]; then warn "git user.name / user.email not set"; return; fi
  [ -z "$name" ]  && { printf 'git user.name: ';  read -r name;  git config --global user.name  "$name"; }
  [ -z "$email" ] && { printf 'git user.email: '; read -r email; git config --global user.email "$email"; }
  ok "git identity set"
}

ensure_ssh() {
  mkdir -p "$HOME/.ssh"; chmod 700 "$HOME/.ssh"
  if [ ! -f "$SSH_KEY" ]; then
    local comment; comment="$(git config --global user.email 2>/dev/null || echo "$USER@$(hostname)")"
    info "Generating an SSH key (ed25519)..."
    if [ "$INTERACTIVE" -eq 0 ]; then ssh-keygen -t ed25519 -f "$SSH_KEY" -C "$comment" -N ""
    else ssh-keygen -t ed25519 -f "$SSH_KEY" -C "$comment"; fi
    ok "SSH key created"
  else
    ok "SSH key present - leaving it untouched"
  fi

  # ssh-add exit codes: 0 = agent has keys, 1 = agent up (no keys), 2 = no agent.
  local rc=0; ssh-add -l >/dev/null 2>&1 || rc=$?
  if [ "$rc" -ne 2 ]; then
    ssh-add "$SSH_KEY" 2>/dev/null && ok "Key added to agent" || warn "Could not add key to the agent"
    local cfg="$HOME/.ssh/config" marker="# template-python bootstrap"
    if [ -f "$cfg" ] && grep -qF "$marker" "$cfg"; then
      ok "~/.ssh/config already configured"
    else
      { printf '\n%s\n' "$marker"; printf 'Host *\n  AddKeysToAgent yes\n  IdentityFile %s\n' "$SSH_KEY"; } >> "$cfg"
      chmod 600 "$cfg"; ok "Persistence added to ~/.ssh/config"
    fi
  else
    warn "No SSH agent in this session - start one (eval \$(ssh-agent)) then re-run to load the key."
  fi
}

# ---- summary --------------------------------------------------------------
summary() {
  hr; printf '%sDone - next steps%s\n' "$BOLD" "$RST"; hr
  if [ -f "$SSH_KEY.pub" ]; then
    echo "Add this SSH public key to your Git forge(s):"; cat "$SSH_KEY.pub"; echo
  fi
  echo "In VS Code: install the Dev Containers extension and set"
  echo "  dev.containers.dockerPath = $(command -v podman || echo podman)"
  echo
  echo "Then create a project:"
  echo "  copier copy --trust $TEMPLATE_URL my-project"
  hr
}

# ---- main -----------------------------------------------------------------
printf '%sPython template - host bootstrap (Linux)%s\n' "$BOLD" "$RST"
doctor
if [ "$CHECK" -eq 1 ]; then exit 0; fi
ensure_podman
ensure_git
ensure_copier
ensure_git_identity
ensure_ssh
summary
