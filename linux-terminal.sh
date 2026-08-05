#!/usr/bin/env bash
#
# Point the terminal at the nerd font on Linux.
#
# macOS gets this for free: install.sh links an iTerm2 dynamic profile with the
# font baked in. On Linux the font was only ever a printed instruction, so a
# fresh machine renders the starship powerline prompt as tofu boxes until the
# user finds the setting themselves.
#
# Terminal emulators here are configured through dconf/gsettings rather than
# files, so this sets the font directly.
#
# An existing custom font is left alone. The iTerm2 profile on macOS is a
# separate profile the user opts into, so it never overwrites their own; doing
# the equivalent here means not touching a terminal that already has a
# deliberate font set. Force a change with DOTFILES_TERMINAL_FONT.
#
# Supported: Ptyxis (Ubuntu 25.10+ default), GNOME Terminal, Console/Kgx.
#
# Exit 0 when everything worked or there was nothing to do (headless, CI).
# Exit 1 only if a terminal was found and setting its font actually failed.
set -uo pipefail

FONT="${DOTFILES_TERMINAL_FONT:-JetBrainsMono Nerd Font Mono 12}"
FORCED="${DOTFILES_TERMINAL_FONT:+yes}"   # explicit request overrides a custom font

info()    { echo -e "\033[0;34m[INFO]\033[0m $1"; }
success() { echo -e "\033[0;32m[OK]\033[0m $1"; }
warning() { echo -e "\033[1;33m[!]\033[0m $1"; }

if ! command -v gsettings >/dev/null 2>&1; then
  info "gsettings not available; skipping terminal font setup"
  exit 0
fi

failures=0
configured=0

# Capture first, then match. Piping into `grep -q` under `set -o pipefail` is a
# trap: grep exits at the first match, gsettings dies with SIGPIPE, and pipefail
# reports the whole pipeline as failed even though the match succeeded.
has_schema() {
  local schemas
  schemas="$(gsettings list-schemas 2>/dev/null)" || return 1
  [[ $'\n'"$schemas"$'\n' == *$'\n'"$1"$'\n'* ]]
}
# Key names differ between terminals and versions, so confirm a key exists
# before setting it rather than relying on the set failing cleanly.
has_key() {
  local keys
  keys="$(gsettings list-keys "$1" 2>/dev/null)" || return 1
  [[ $'\n'"$keys"$'\n' == *$'\n'"$2"$'\n'* ]]
}

# apply <label> <schema[:path]> <system-font-key> <font-key>
apply() {
  local label="$1" schema="$2" sys_key="$3" font_key="$4"

  if ! has_key "$schema" "$font_key"; then
    warning "$label: no '$font_key' key in this version; set the font manually"
    return 0
  fi

  # Respect a font the user chose themselves.
  if [[ -z "$FORCED" ]] && has_key "$schema" "$sys_key"; then
    local using_system current
    using_system="$(gsettings get "$schema" "$sys_key" 2>/dev/null)"
    if [[ "$using_system" == "false" ]]; then
      current="$(gsettings get "$schema" "$font_key" 2>/dev/null | tr -d "\"'")"
      info "$label already set to '$current'; leaving it alone"
      info "  override with: DOTFILES_TERMINAL_FONT='$FONT' $0"
      configured=1
      return 0
    fi
  fi

  local previous=""
  previous="$(gsettings get "$schema" "$font_key" 2>/dev/null | tr -d "\"'")"

  if { ! has_key "$schema" "$sys_key" || gsettings set "$schema" "$sys_key" false 2>/dev/null; } &&
     gsettings set "$schema" "$font_key" "$FONT" 2>/dev/null; then
    if [[ -n "$previous" && "$previous" != "$FONT" ]]; then
      success "$label font set to $FONT (was '$previous')"
    else
      success "$label font set to $FONT"
    fi
    configured=1
  else
    warning "Could not set the $label font"
    failures=$((failures + 1))
  fi
}

# --- Ptyxis: the default terminal on Ubuntu 25.10+ -------------------------
has_schema org.gnome.Ptyxis && apply "Ptyxis" org.gnome.Ptyxis use-system-font font-name

# --- GNOME Terminal: per-profile, so resolve the default profile UUID ------
if has_schema org.gnome.Terminal.ProfilesList; then
  profile="$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d "\"'")"
  if [[ -n "${profile:-}" ]]; then
    apply "GNOME Terminal" \
          "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${profile}/" \
          use-system-font font
  fi
fi

# --- GNOME Console (kgx) ---------------------------------------------------
# Key names are checked at runtime by apply(), so this stays correct even if
# they differ from what we expect on a given version.
has_schema org.gnome.Console && apply "GNOME Console" org.gnome.Console use-system-font custom-font

if [[ "$configured" -eq 0 && "$failures" -eq 0 ]]; then
  warning "No supported terminal found. Set your terminal font to: $FONT"
fi

# A running terminal caches fontconfig at startup, so a newly installed font is
# invisible to it until the process fully restarts -- a new tab or window in the
# same process is not enough. Worth saying, because it looks like the font
# simply failed to install.
[[ "$configured" -eq 1 ]] && info "Fully quit and reopen your terminal for the font to take effect"

exit $(( failures > 0 ? 1 : 0 ))
