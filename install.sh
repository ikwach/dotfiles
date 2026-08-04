#!/usr/bin/env bash
#
# Dotfiles installer
#
# Usage:
#   ./install.sh personal    # full setup: core + AI, cloud, media tools
#   ./install.sh corporate   # restricted setup: core CLI tools only
#
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

BLUE='\033[0;34m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warning() { echo -e "${YELLOW}[!]${NC} $1"; }
fail()    { echo -e "${RED}[ERR]${NC} $1"; exit 1; }

# ----------------------------------------
# Mode selection
# ----------------------------------------

MODE="${1:-}"
if [[ -z "$MODE" ]]; then
  if [[ -t 0 ]]; then
    echo "Select installation mode:"
    echo "  1) personal   - everything: core tools + AI, cloud, media"
    echo "  2) corporate  - restricted: core CLI tools only"
    read -rp "Mode [1/2]: " choice
    case "$choice" in
      1) MODE="personal" ;;
      2) MODE="corporate" ;;
      *) fail "Invalid choice" ;;
    esac
  else
    fail "No mode given. Usage: ./install.sh personal|corporate"
  fi
fi
[[ "$MODE" == "personal" || "$MODE" == "corporate" ]] || fail "Unknown mode: $MODE (use personal|corporate)"

[[ "$OSTYPE" == darwin* ]] || fail "This script only supports macOS"

echo ""
info "Mode: $MODE"
info "Dotfiles: $DOTFILES_DIR"
echo ""

# ----------------------------------------
# Homebrew
# ----------------------------------------

if ! command -v brew >/dev/null 2>&1; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ "$(uname -m)" == "arm64" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    grep -q 'brew shellenv' "$HOME/.zprofile" 2>/dev/null || \
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
  fi
fi
success "Homebrew ready"

# A single blocked package (e.g. a cask denied by MDM policy) should not
# abort the whole install before symlinks and identity are set up.
info "Installing packages (this can take a while)..."
if [[ "$MODE" == "personal" ]]; then
  cat "$DOTFILES_DIR/Brewfile.core" "$DOTFILES_DIR/Brewfile.personal" | brew bundle --file=- \
    || warning "Some packages failed to install; continuing with setup"
else
  brew bundle --file="$DOTFILES_DIR/Brewfile.core" \
    || warning "Some packages failed to install; continuing with setup"
fi
success "Package installation finished"

# ----------------------------------------
# Symlinks (existing regular files are backed up first)
# ----------------------------------------

# Backups mirror the path under $HOME so same-named files cannot collide,
# and the original is only removed once the copy has succeeded.
link() {
  local source="$1" target="$2"
  if [[ -e "$target" && ! -L "$target" ]]; then
    local rel="${target#"$HOME"/}"
    mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
    cp -r "$target" "$BACKUP_DIR/$rel" || fail "Could not back up $target, aborting before overwriting it"
    rm -rf "$target"
  fi
  mkdir -p "$(dirname "$target")"
  ln -sfn "$source" "$target"
  success "Linked $target"
}

info "Linking dotfiles..."
link "$DOTFILES_DIR/zsh/.zshrc"                          "$HOME/.zshrc"
link "$DOTFILES_DIR/zsh/.zsh_plugins.txt"                "$HOME/.zsh_plugins.txt"
link "$DOTFILES_DIR/starship/starship.toml"              "$HOME/.config/starship.toml"
link "$DOTFILES_DIR/git/.gitconfig"                      "$HOME/.gitconfig"
link "$DOTFILES_DIR/git/ignore"                          "$HOME/.config/git/ignore"
link "$DOTFILES_DIR/themes/delta/catppuccin.gitconfig"   "$HOME/.config/delta/catppuccin.gitconfig"
link "$DOTFILES_DIR/tmux/.tmux.conf"                     "$HOME/.tmux.conf"
link "$DOTFILES_DIR/bat/config"                          "$HOME/.config/bat/config"
link "$DOTFILES_DIR/themes/bat/Catppuccin Mocha.tmTheme" "$HOME/.config/bat/themes/Catppuccin Mocha.tmTheme"
link "$DOTFILES_DIR/themes/eza/catppuccin-mocha.yml"     "$HOME/.config/eza/theme.yml"
link "$DOTFILES_DIR/themes/btop/catppuccin_mocha.theme"  "$HOME/.config/btop/themes/catppuccin_mocha.theme"
link "$DOTFILES_DIR/lazygit/config.yml"                  "$HOME/.config/lazygit/config.yml"
link "$DOTFILES_DIR/tealdeer/config.toml"                "$HOME/Library/Application Support/tealdeer/config.toml"

# bin/ scripts onto PATH (gifenc needs ffmpeg, which only personal mode installs)
mkdir -p "$HOME/.local/bin"
for script in "$DOTFILES_DIR"/bin/*; do
  [[ -f "$script" ]] || continue
  name="$(basename "$script")"
  [[ "$MODE" == "corporate" && "$name" == "gifenc" ]] && continue
  ln -sfn "$script" "$HOME/.local/bin/$name"
done
success "Linked bin/ scripts to ~/.local/bin"

if [[ -f "$HOME/.gitignore_global" ]]; then
  warning "The old ~/.gitignore_global is no longer used; global ignores now live in ~/.config/git/ignore"
fi

[[ -d "$BACKUP_DIR" ]] && info "Previous configs backed up to $BACKUP_DIR"

# ----------------------------------------
# Git identity (kept out of the repo)
# ----------------------------------------

if [[ ! -f "$HOME/.gitconfig.local" ]]; then
  info "Setting up git identity (${MODE} mode)..."
  if [[ -t 0 ]]; then
    read -rp "Git name: " git_name
    if [[ "$MODE" == "corporate" ]]; then
      read -rp "Git email (use your WORK email): " git_email
    else
      read -rp "Git email: " git_email
    fi
    printf '[user]\n\tname = %s\n\temail = %s\n' "$git_name" "$git_email" > "$HOME/.gitconfig.local"
    success "Wrote ~/.gitconfig.local"
  else
    warning "Non-interactive shell: create ~/.gitconfig.local with your [user] name/email"
  fi
else
  success "Git identity already configured (~/.gitconfig.local)"
fi

# ----------------------------------------
# Secrets file
# ----------------------------------------

if [[ ! -f "$HOME/.secrets.env" ]]; then
  cat > "$HOME/.secrets.env" <<'EOF'
# API keys and tokens - sourced by .zshrc, never committed anywhere.
# Prefer 1Password CLI where possible:  export MY_KEY="$(op read 'op://vault/item/field')"
# export OPENAI_API_KEY="..."
# export ANTHROPIC_API_KEY="..."
EOF
fi
chmod 600 "$HOME/.secrets.env"
success "Secrets file ready (~/.secrets.env, chmod 600)"

# ----------------------------------------
# Tool setup
# ----------------------------------------

info "Building bat theme cache..."
bat cache --build >/dev/null && success "bat themes ready"

# btop rewrites its config on exit, so copy a default instead of symlinking
if [[ ! -f "$HOME/.config/btop/btop.conf" ]]; then
  printf 'color_theme = "catppuccin_mocha"\ntheme_background = False\nvim_keys = True\n' > "$HOME/.config/btop/btop.conf"
  success "btop config created"
fi

if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  info "Installing tmux plugin manager..."
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  success "TPM installed (prefix + I inside tmux installs plugins)"
fi

info "Updating tldr cache..."
tldr --update >/dev/null 2>&1 && success "tldr cache updated"

if [[ "$SHELL" != *zsh ]]; then
  info "Setting zsh as default shell..."
  chsh -s "$(command -v zsh)" || warning "Could not change the default shell; run chsh manually"
fi

# ----------------------------------------
# Done
# ----------------------------------------

echo ""
success "Installation complete ($MODE mode)."
echo ""
info "Next steps:"
echo "  1. Restart your terminal"
echo "  2. iTerm2 theme: Settings > Profiles > Colors > Color Presets > Import"
echo "     -> $DOTFILES_DIR/themes/iterm/catppuccin-mocha.itermcolors"
echo "     then Settings > Profiles > Text > Font -> JetBrainsMono Nerd Font"
echo "  3. Runtime versions:    mise use -g node@lts"
echo "  4. Import history:      atuin import zsh"
if [[ "$MODE" == "personal" ]]; then
  echo "  5. Sign in:             claude   /   gcloud auth login   /   op signin"
fi
echo ""
