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
# Everything is skipped when already present, so this is safe to re-run.
set -uo pipefail

info()    { echo -e "\033[0;34m[INFO]\033[0m $1"; }
success() { echo -e "\033[0;32m[OK]\033[0m $1"; }
warning() { echo -e "\033[1;33m[!]\033[0m $1"; }

command -v apt-get >/dev/null 2>&1 || { warning "Not a Debian/Ubuntu system; skipping Linux extras"; exit 0; }

# gcloud and 1Password add apt repositories, which needs a usable sudo. Claude
# Code installs into $HOME and does not.
have_sudo() { sudo -n true 2>/dev/null || { [[ -t 0 ]] && sudo -v 2>/dev/null; }; }

# --- Claude Code -----------------------------------------------------------
# Native installer; lands in ~/.local/bin/claude and self-updates.
# https://code.claude.com/docs/en/setup
if command -v claude >/dev/null 2>&1; then
  success "Claude Code already installed"
else
  info "Installing Claude Code..."
  if curl -fsSL https://claude.ai/install.sh | bash; then
    success "Claude Code installed (run 'claude' to sign in)"
  else
    warning "Claude Code install failed; see https://code.claude.com/docs/en/setup"
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
  if curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg \
        | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg &&
     echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
        | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list >/dev/null &&
     sudo apt-get update -qq && sudo apt-get install -y -qq google-cloud-cli; then
    success "gcloud installed (run 'gcloud auth login')"
  else
    warning "gcloud install failed; see https://docs.cloud.google.com/sdk/docs/install"
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
  if curl -sS https://downloads.1password.com/linux/keys/1password.asc \
        | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg &&
     echo "deb [arch=$arch signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$arch stable main" \
        | sudo tee /etc/apt/sources.list.d/1password.list >/dev/null &&
     sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/ &&
     curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol \
        | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol >/dev/null &&
     sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22 &&
     curl -sS https://downloads.1password.com/linux/keys/1password.asc \
        | sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg &&
     sudo apt-get update -qq && sudo apt-get install -y -qq 1password-cli; then
    success "1Password CLI installed (run 'op signin')"
  else
    warning "1Password CLI install failed; see https://www.1password.dev/cli/get-started/"
  fi
fi

info "Claude desktop app on Linux: https://code.claude.com/docs/en/desktop-linux"
exit 0
