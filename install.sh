#!/usr/bin/env bash
#
# Dotfiles installer for macOS and Linux (Debian/Ubuntu)
#
# Usage:
#   ./install.sh personal    # full setup: core + AI, cloud, media tools
#   ./install.sh corporate   # restricted setup: core CLI tools only
#
# Packages come from Homebrew on both OSes (one manifest, same versions).
# On Linux, apt only bootstraps Homebrew's build deps; casks and mas are
# macOS-only and live in Brewfile.macos.
#
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

BLUE='\033[0;34m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warning() { echo -e "${YELLOW}[!]${NC} $1"; }
fail()    { echo -e "${RED}[ERR]${NC} $1"; exit 1; }

case "$OSTYPE" in
  darwin*) OS="macos" ;;
  linux*)  OS="linux" ;;
  *)       fail "Unsupported OS: $OSTYPE" ;;
esac

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

echo ""
info "Mode: $MODE ($OS)"
info "Dotfiles: $DOTFILES_DIR"
echo ""

# ----------------------------------------
# Homebrew
# ----------------------------------------

if ! command -v brew >/dev/null 2>&1; then
  if [[ "$OS" == "linux" ]] && command -v apt-get >/dev/null 2>&1; then
    info "Installing Homebrew build dependencies via apt..."
    if ! (sudo apt-get update -qq && sudo apt-get install -y -qq \
        build-essential procps curl file git zsh fontconfig); then
      warning "apt dependencies failed; Homebrew install may not work"
    fi
  fi
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Make brew available in this script and in future login shells
# ($HOME/.linuxbrew is the installer's fallback when sudo is unavailable)
for brew_bin in /opt/homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew "$HOME/.linuxbrew/bin/brew" /usr/local/bin/brew; do
  if [[ -x "$brew_bin" ]]; then
    eval "$("$brew_bin" shellenv)"
    grep -q 'brew shellenv' "$HOME/.zprofile" 2>/dev/null || \
      echo "eval \"\$($brew_bin shellenv)\"" >> "$HOME/.zprofile"
    break
  fi
done
command -v brew >/dev/null 2>&1 || fail "Homebrew is not available after install"
success "Homebrew ready"

# A single blocked package (e.g. a cask denied by MDM policy) should not
# abort the whole install before symlinks and identity are set up.
compose_brewfile() {
  cat "$DOTFILES_DIR/Brewfile.core"
  [[ "$OS" == "macos" ]] && cat "$DOTFILES_DIR/Brewfile.macos"
  [[ "$MODE" == "personal" ]] && cat "$DOTFILES_DIR/Brewfile.personal"
  return 0
}

info "Installing packages (this can take a while)..."
if [[ "$OS" == "linux" ]]; then
  # Casks are a macOS concept; drop any that appear in Brewfile.personal
  compose_brewfile | grep -v '^cask ' | brew bundle --file=- \
    || warning "Some packages failed to install; continuing with setup"
else
  compose_brewfile | brew bundle --file=- \
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

if [[ "$OS" == "macos" ]]; then
  TEALDEER_CONFIG="$HOME/Library/Application Support/tealdeer/config.toml"
else
  TEALDEER_CONFIG="$HOME/.config/tealdeer/config.toml"
fi

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
link "$DOTFILES_DIR/nvim"                                "$HOME/.config/nvim"
link "$DOTFILES_DIR/tealdeer/config.toml"                "$TEALDEER_CONFIG"

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
# Nerd Font (Linux; macOS gets it as a cask)
# ----------------------------------------

if [[ "$OS" == "linux" ]] && command -v fc-cache >/dev/null 2>&1; then
  FONT_DIR="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
  if [[ ! -d "$FONT_DIR" ]]; then
    info "Installing JetBrains Mono Nerd Font..."
    font_tmp="$(mktemp -d)"
    if curl -fsSL -o "$font_tmp/JetBrainsMono.tar.xz" \
        "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz" \
        && mkdir -p "$FONT_DIR" \
        && tar -xJf "$font_tmp/JetBrainsMono.tar.xz" -C "$FONT_DIR"; then
      fc-cache -f "$FONT_DIR" >/dev/null || true
      success "Nerd Font installed (set it in your terminal profile)"
    else
      warning "Font download failed; install a Nerd Font manually for prompt icons"
    fi
    rm -rf "$font_tmp"
  fi
fi

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

if command -v bat >/dev/null 2>&1; then
  info "Building bat theme cache..."
  bat cache --build >/dev/null && success "bat themes ready"
fi

# btop rewrites its config on exit, so copy a default instead of symlinking.
# dracula ships with btop; the vendored catppuccin theme stays available too.
if [[ ! -f "$HOME/.config/btop/btop.conf" ]]; then
  mkdir -p "$HOME/.config/btop"
  printf 'color_theme = "dracula"\ntheme_background = False\nvim_keys = True\n' > "$HOME/.config/btop/btop.conf"
  success "btop config created"
fi

if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  info "Installing tmux plugin manager..."
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  success "TPM installed (prefix + I inside tmux installs plugins)"
fi

if command -v tldr >/dev/null 2>&1; then
  info "Updating tldr cache..."
  tldr --update >/dev/null 2>&1 && success "tldr cache updated"
fi

if [[ "$SHELL" != *zsh ]] && command -v zsh >/dev/null 2>&1; then
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
if [[ "$OS" == "macos" ]]; then
  echo "  2. iTerm2 theme: Settings > Profiles > Colors > Color Presets > Import"
  echo "     -> $DOTFILES_DIR/themes/iterm/dracula-plus.itermcolors"
  echo "     (catppuccin-mocha.itermcolors is there too if you prefer)"
  echo "     then Settings > Profiles > Text > Font -> JetBrainsMono Nerd Font"
else
  echo "  2. Set your terminal font to JetBrainsMono Nerd Font"
  echo "     (GNOME Terminal catppuccin: github.com/catppuccin/gnome-terminal)"
fi
echo "  3. Runtime versions:    mise use -g node@lts"
echo "  4. Import history:      atuin import zsh"
if [[ "$MODE" == "personal" ]]; then
  if [[ "$OS" == "macos" ]]; then
    echo "  5. Sign in:             claude   /   gcloud auth login   /   op signin"
  else
    echo "  5. Casks are macOS-only: install Claude Code, gcloud and the"
    echo "     1Password CLI from their vendor instructions, then sign in"
  fi
fi
echo ""
