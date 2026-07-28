#!/usr/bin/env bash
# Host bootstrap for the Python template - macOS.
#
# Verifies (and installs when missing) the tools you need to generate and work
# on projects from the template: Copier, git, a git identity, and an SSH key.
# Idempotent: re-running only fixes what is missing, and it never overwrites an
# existing SSH key.
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

# git ships with the Xcode Command Line Tools; xcode-select -p is true once they
# are installed (checking this way does not trigger the install popup).
git_ready() { have git && xcode-select -p >/dev/null 2>&1; }

# ---- doctor ---------------------------------------------------------------
doctor() {
  hr; printf '%sDoctor - current state%s\n' "$BOLD" "$RST"; hr
  if git_ready; then ok "git: present"; else warn "git: not found (will install)"; fi
  if have copier; then ok "Copier: present"; else warn "Copier: missing (will install)"; fi
  if [ -f "$SSH_KEY" ]; then ok "SSH key: $SSH_KEY"; else warn "SSH key: none (will generate)"; fi
  hr
}

# ---- actions --------------------------------------------------------------
ensure_git() {
  if git_ready; then ok "git present"; return; fi
  info "Installing the Xcode Command Line Tools (provides git)..."
  xcode-select --install 2>/dev/null || true
  warn "Finish the Command Line Tools install in the popup, then re-run this script."
}

ensure_copier() {
  if have copier; then ok "Copier already installed"; return; fi
  if ! have uv && ! have pipx; then
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

  # macOS keeps the ssh-agent running via launchd; --apple-use-keychain stores
  # the passphrase in the login Keychain so the key loads again on every reboot.
  ssh-add --apple-use-keychain "$SSH_KEY" 2>/dev/null && ok "Key added to agent (Keychain)" \
    || warn "Could not add the key to the agent"

  local cfg="$HOME/.ssh/config" marker="# template-python bootstrap"
  if [ -f "$cfg" ] && grep -qF "$marker" "$cfg"; then
    ok "~/.ssh/config already configured"
  else
    { printf '\n%s\n' "$marker"
      printf 'Host *\n  AddKeysToAgent yes\n  UseKeychain yes\n  IdentityFile %s\n' "$SSH_KEY"
    } >> "$cfg"
    chmod 600 "$cfg"; ok "Persistence added to ~/.ssh/config"
  fi
}

# ---- summary --------------------------------------------------------------
summary() {
  hr; printf '%sDone - next steps%s\n' "$BOLD" "$RST"; hr
  if [ -f "$SSH_KEY.pub" ]; then
    echo "Add this SSH public key to your Git forge(s):"; cat "$SSH_KEY.pub"; echo
  fi
  echo "Then create a project:"
  echo "  copier copy --trust $TEMPLATE_URL my-project"
  hr
}

# ---- main -----------------------------------------------------------------
printf '%sPython template - host bootstrap (macOS)%s\n' "$BOLD" "$RST"
doctor
if [ "$CHECK" -eq 1 ]; then exit 0; fi
ensure_git
ensure_copier
ensure_git_identity
ensure_ssh
summary
