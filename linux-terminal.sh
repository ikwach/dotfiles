#!/usr/bin/env bash
#
# Configure the terminal font on Linux.
#
# macOS gets this for free: install.sh links an iTerm2 dynamic profile with the
# nerd font baked in. On Linux the font was only ever a printed instruction, so
# a fresh machine renders the starship powerline prompt as tofu boxes until the
# user finds the setting themselves.
#
# Terminal emulators here are configured through dconf/gsettings rather than
# files, so this sets the font directly.
#
# Supported: Ptyxis (Ubuntu 25.10+ default), GNOME Terminal, Console/Kgx.
# Anything else prints the font name to set manually.
#
# Safe to run repeatedly. Exits 0 on headless machines and in CI.
set -uo pipefail

FONT="${DOTFILES_TERMINAL_FONT:-JetBrainsMono Nerd Font Mono 12}"

info()    { echo -e "\033[0;34m[INFO]\033[0m $1"; }
success() { echo -e "\033[0;32m[OK]\033[0m $1"; }
warning() { echo -e "\033[1;33m[!]\033[0m $1"; }

# No gsettings (headless, container, CI) -> nothing to do, and not an error.
if ! command -v gsettings >/dev/null 2>&1; then
  info "gsettings not available; skipping terminal font setup"
  exit 0
fi

has_schema() { gsettings list-schemas 2>/dev/null | grep -qx "$1"; }

configured=0

# --- Ptyxis: the default terminal on Ubuntu 25.10+ -------------------------
if has_schema org.gnome.Ptyxis; then
  if gsettings set org.gnome.Ptyxis use-system-font false 2>/dev/null &&
     gsettings set org.gnome.Ptyxis font-name "$FONT" 2>/dev/null; then
    success "Ptyxis font set to $FONT"
    configured=1
  else
    warning "Could not set the Ptyxis font"
  fi
fi

# --- GNOME Terminal: per-profile, so resolve the default profile UUID ------
if has_schema org.gnome.Terminal.ProfilesList; then
  profile="$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d \"\')"
  if [[ -n "${profile:-}" ]]; then
    path="/org/gnome/terminal/legacy/profiles:/:${profile}/"
    if gsettings set "org.gnome.Terminal.Legacy.Profile:$path" use-system-font false 2>/dev/null &&
       gsettings set "org.gnome.Terminal.Legacy.Profile:$path" font "$FONT" 2>/dev/null; then
      success "GNOME Terminal font set to $FONT"
      configured=1
    else
      warning "Could not set the GNOME Terminal font"
    fi
  fi
fi

# --- GNOME Console (kgx) ---------------------------------------------------
if has_schema org.gnome.Console; then
  if gsettings set org.gnome.Console use-system-font false 2>/dev/null &&
     gsettings set org.gnome.Console custom-font "$FONT" 2>/dev/null; then
    success "GNOME Console font set to $FONT"
    configured=1
  fi
fi

if [[ "$configured" -eq 0 ]]; then
  warning "No supported terminal found. Set your terminal font to: $FONT"
fi

# A running terminal caches fontconfig at startup, so a newly installed font is
# invisible to it until the process fully restarts -- a new tab or window in the
# same process is not enough. Worth saying, because it looks like the font
# simply failed to install.
info "Fully quit and reopen your terminal for the font to take effect"
exit 0
