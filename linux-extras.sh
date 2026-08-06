#!/usr/bin/env bash
#
# Personal-mode tools that ship as Homebrew casks on macOS.
#
# install.sh strips `cask` lines on Linux, so personal mode there silently ends
# up without Claude Code, the gcloud CLI and the 1Password CLI -- the installer
# just prints "install these yourself". This installs them from the vendors'
# official Linux channels instead.
#
# Deliberately NOT covered:
#   claude (desktop app)  - see https://code.claude.com/docs/en/desktop-linux
#
# Exits non-zero if a tool actually failed to install, so the caller can report
# it. Tools that are already present, or skipped for want of sudo, are not
# failures.
set -uo pipefail

info()    { echo -e "\033[0;34m[INFO]\033[0m $1"; }
success() { echo -e "\033[0;32m[OK]\033[0m $1"; }
warning() { echo -e "\033[1;33m[!]\033[0m $1"; }

failures=0

command -v apt-get >/dev/null 2>&1 || { warning "Not a Debian/Ubuntu system; skipping Linux extras"; exit 0; }

# The documented greenfield path is `curl ... | bash -s -- personal`, where
# stdin is the curl pipe all the way through install.sh -- so `[[ -t 0 ]]` is
# false even though a user is sitting there. Ask the terminal directly, which is
# what makes the advertised one-liner actually install these.
#
# Open /dev/tty rather than testing that it exists: on CI runners and in
# containers the device node is present with no controlling terminal. Same probe
# as install.sh's have_tty().
have_sudo() {
  sudo -n true 2>/dev/null && return 0
  (exec 3</dev/tty) 2>/dev/null || return 1
  sudo -v </dev/tty 2>/dev/null
}

# Both apt repositories below need gpg to dearmor their signing keys, and
# neither bootstrap.sh nor install.sh guarantees gnupg on a minimal image.
ensure_gnupg() {
  command -v gpg >/dev/null 2>&1 && return 0
  info "Installing gnupg (required to verify the repository keys)..."
  sudo apt-get update -qq && sudo apt-get install -y -qq gnupg
}

# --- Claude Code -----------------------------------------------------------
# Native installer; lands in ~/.local/bin/claude and self-updates.
# https://code.claude.com/docs/en/setup
#
# ~/.local/bin is put on PATH by zsh/.zshrc, but this script runs under bash,
# so check the path directly as well or a re-run downloads it again.
if command -v claude >/dev/null 2>&1 || [[ -x "$HOME/.local/bin/claude" ]]; then
  success "Claude Code already installed"
else
  info "Installing Claude Code..."
  if curl -fsSL https://claude.ai/install.sh | bash; then
    success "Claude Code installed (run 'claude' to sign in)"
  else
    warning "Claude Code install failed; see https://code.claude.com/docs/en/setup"
    failures=$((failures + 1))
  fi
fi

# --- Google Cloud CLI ------------------------------------------------------
# https://docs.cloud.google.com/sdk/docs/install
if command -v gcloud >/dev/null 2>&1; then
  success "gcloud already installed"
elif ! have_sudo; then
  warning "sudo unavailable; skipping gcloud (needs an apt repository)"
else
  info "Installing Google Cloud CLI..."
  # --batch --yes: without them gpg prompts before overwriting an existing
  # keyring and blocks the installer. The keyring outlives the package, so this
  # fires on any re-run after a failed apt step, after `apt remove`, or for
  # anyone who already followed Google's docs by hand.
  if ensure_gnupg &&
     curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg \
       | sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/cloud.google.gpg &&
     echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
       | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list >/dev/null &&
     sudo apt-get update -qq && sudo apt-get install -y -qq google-cloud-cli; then
    success "gcloud installed (run 'gcloud auth login')"
  else
    warning "gcloud install failed; see https://docs.cloud.google.com/sdk/docs/install"
    failures=$((failures + 1))
  fi
fi

# --- 1Password CLI ---------------------------------------------------------
# https://www.1password.dev/cli/get-started/
if command -v op >/dev/null 2>&1; then
  success "1Password CLI already installed"
elif ! have_sudo; then
  warning "sudo unavailable; skipping 1Password CLI (needs an apt repository)"
else
  info "Installing 1Password CLI..."
  arch="$(dpkg --print-architecture)"
  if ensure_gnupg &&
     curl -sS https://downloads.1password.com/linux/keys/1password.asc \
       | sudo gpg --batch --yes --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg &&
     echo "deb [arch=$arch signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$arch stable main" \
       | sudo tee /etc/apt/sources.list.d/1password.list >/dev/null &&
     sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/ &&
     curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol \
       | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol >/dev/null &&
     sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22 &&
     curl -sS https://downloads.1password.com/linux/keys/1password.asc \
       | sudo gpg --batch --yes --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg &&
     sudo apt-get update -qq && sudo apt-get install -y -qq 1password-cli; then
    success "1Password CLI installed (run 'op signin')"
  else
    warning "1Password CLI install failed; see https://www.1password.dev/cli/get-started/"
    failures=$((failures + 1))
  fi
fi

info "Claude desktop app on Linux: https://code.claude.com/docs/en/desktop-linux"
exit $(( failures > 0 ? 1 : 0 ))
