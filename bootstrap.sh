#!/usr/bin/env bash
#
# Greenfield bootstrap: takes a clean macOS or Ubuntu machine to a full setup.
#
#   curl -fsSL https://raw.githubusercontent.com/ikwach/dotfiles/master/bootstrap.sh | bash -s -- personal
#   wget -qO-  https://raw.githubusercontent.com/ikwach/dotfiles/master/bootstrap.sh | bash -s -- corporate
#
# Extra flags are passed through to install.sh:
#   --with-macos-defaults   apply opt-in macOS system settings (macos.sh)
#   --with-mac-keys         install Toshy mac-style shortcuts (Linux only)
#
set -euo pipefail

REPO_URL="https://github.com/ikwach/dotfiles.git"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/workspace/dotfiles}"

info()    { echo "[bootstrap] $1"; }
warning() { echo "[bootstrap] WARN: $1" >&2; }
fail()    { echo "[bootstrap] ERROR: $1" >&2; exit 1; }

case "$OSTYPE" in
  darwin*)
    # Command Line Tools ship git; install and wait if missing
    if ! xcode-select -p >/dev/null 2>&1; then
      info "Installing Xcode Command Line Tools; accept the dialog that appears..."
      xcode-select --install >/dev/null 2>&1 || true
      until xcode-select -p >/dev/null 2>&1; do sleep 10; done
      info "Command Line Tools installed"
    fi
    ;;
  linux*)
    # minimal Ubuntu images often ship without git or even curl
    if command -v apt-get >/dev/null 2>&1; then
      if ! command -v git >/dev/null 2>&1 || ! command -v curl >/dev/null 2>&1; then
        info "Installing git and curl via apt..."
        sudo apt-get update -qq
        sudo apt-get install -y -qq git curl ca-certificates
      fi
    fi
    command -v git >/dev/null 2>&1 || fail "git is required and could not be installed"
    ;;
  *) fail "Unsupported OS: $OSTYPE" ;;
esac

# When run from inside a checkout (CI, reruns) use it; otherwise clone
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-.}")" 2>/dev/null && pwd || true)"
if [[ -n "$SCRIPT_DIR" && -f "$SCRIPT_DIR/install.sh" ]]; then
  DOTFILES_DIR="$SCRIPT_DIR"
elif [[ -d "$DOTFILES_DIR/.git" ]]; then
  info "Updating existing clone at $DOTFILES_DIR"
  # Our own git/.gitconfig sets rebase.autoStash, so a dirty clone makes this
  # pull create a stash commit first -- and a machine whose git identity is
  # missing or half-written (an empty name in ~/.gitconfig.local) cannot
  # create any commit: git aborts before the fast-forward and the run
  # continues on the stale clone, which is exactly how a broken installer
  # keeps reinstalling itself. The stash is local and momentary, so a
  # throwaway ident is fine; it must not depend on the very identity this
  # repo's installer is about to set up.
  git -C "$DOTFILES_DIR" -c user.name=bootstrap -c user.email=bootstrap@localhost \
    pull --ff-only || warning "Could not fast-forward; using the clone as is"
else
  info "Cloning dotfiles to $DOTFILES_DIR"
  mkdir -p "$(dirname "$DOTFILES_DIR")"
  git clone "$REPO_URL" "$DOTFILES_DIR"
fi

exec "$DOTFILES_DIR/install.sh" "$@"
