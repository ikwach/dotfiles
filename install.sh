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

# The documented install is `curl ... | bash -s -- personal`, where stdin is the
# curl pipe for the whole run -- so `[[ -t 0 ]]` is false even with a user sat
# right there. Ask the terminal directly instead. Anything that prompts must use
# this and read from /dev/tty, or it silently takes the non-interactive path on
# the exact command the README recommends.
#
# Actually open /dev/tty rather than just testing that it exists: on CI runners
# and in containers the device node is present but has no controlling terminal,
# so the open fails -- and a failed redirect on `read` would abort the whole
# installer under `set -e`.
# No `[[ -t 0 ]] && return 0` shortcut: every caller reads from /dev/tty, so
# what matters is whether that open succeeds, not whether stdin is a terminal.
# Returning early on the stdin check could green-light a redirect that then
# fails, aborting the installer under set -e.
have_tty() { (exec 3</dev/tty) 2>/dev/null; }

# ----------------------------------------
# Mode selection
# ----------------------------------------

MODE=""
WITH_MACOS_DEFAULTS=0
WITH_MAC_KEYS=0
for arg in "$@"; do
  case "$arg" in
    personal|corporate)     MODE="$arg" ;;
    --with-macos-defaults)  WITH_MACOS_DEFAULTS=1 ;;
    --with-mac-keys)        WITH_MAC_KEYS=1 ;;
    *) fail "Unknown argument: $arg (usage: ./install.sh personal|corporate [--with-macos-defaults] [--with-mac-keys])" ;;
  esac
done
if [[ -z "$MODE" ]]; then
  if have_tty; then
    echo "Select installation mode:"
    echo "  1) personal   - everything: core tools + AI, cloud, media"
    echo "  2) corporate  - restricted: core CLI tools only"
    read -rp "Mode [1/2]: " choice </dev/tty
    case "$choice" in
      1) MODE="personal" ;;
      2) MODE="corporate" ;;
      *) fail "Invalid choice" ;;
    esac
  else
    fail "No mode given. Usage: ./install.sh personal|corporate"
  fi
fi

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
    # gnupg is not a Homebrew dependency, but linux-extras.sh needs it to
    # dearmor the gcloud and 1Password repository keys, and minimal images
    # do not ship it.
    if ! (sudo apt-get update -qq && sudo apt-get install -y -qq \
        build-essential procps curl file git zsh fontconfig gnupg); then
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
    shellenv_line="eval \"\$($brew_bin shellenv)\""
    # Match this exact brew, not any 'brew shellenv' line. Migrating Intel ->
    # ARM (/usr/local -> /opt/homebrew), or /home/linuxbrew -> ~/.linuxbrew,
    # otherwise leaves the stale line in place and never adds the right one,
    # producing a broken login shell that re-running cannot repair.
    if ! grep -qxF "$shellenv_line" "$HOME/.zprofile" 2>/dev/null; then
      # Drop a shellenv line pointing at a different prefix. Anchored to the
      # exact shape the installer writes, so a line a user wrote themselves that
      # merely mentions "brew shellenv" is left alone.
      stale_re='^[[:space:]]*eval "\$\(.*brew shellenv\)"[[:space:]]*$'
      if [[ -f "$HOME/.zprofile" ]] && grep -qE "$stale_re" "$HOME/.zprofile"; then
        mkdir -p "$BACKUP_DIR"
        cp "$HOME/.zprofile" "$BACKUP_DIR/.zprofile"
        # `grep -v` exits 1 when it filters out every line, which is exactly the
        # single-line .zprofile the old installer wrote -- so `&& mv` silently
        # skipped, leaving the stale line and an orphaned .tmp behind.
        grep -vE "$stale_re" "$HOME/.zprofile" > "$HOME/.zprofile.tmp" || true
        mv "$HOME/.zprofile.tmp" "$HOME/.zprofile"
        warning "Replaced a stale brew shellenv line in ~/.zprofile (backed up)"
      fi
      # printf, not echo: a file with no trailing newline would otherwise get
      # this appended to its last line, silently corrupting both.
      printf '\n%s\n' "$shellenv_line" >> "$HOME/.zprofile"
    fi
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

# Homebrew 6 refuses formulae from untrusted third-party taps, and one
# refusal aborts the whole batched bundle install. Taps declared in our
# Brewfiles are trusted by virtue of being committed here.
if brew trust --help >/dev/null 2>&1; then
  while IFS= read -r tap_name; do
    brew trust --tap "$tap_name" >/dev/null 2>&1 || warning "Could not trust tap $tap_name"
  done < <(compose_brewfile | awk -F'"' '/^tap /{print $2}')
fi

# A claude binary Homebrew does not own -- npm's global bin, an old manual
# copy, or a symlink left behind by a purged cask -- makes the claude-code
# cask abort with "already a Binary", failing the bundle run every time.
# Move it aside (backed up) so the cask can own the path and its updates.
# -L as well as -e: a dangling symlink fails -e but still blocks the cask.
if [[ "$OS" == "macos" && "$MODE" == "personal" ]]; then
  brew_claude="$(brew --prefix)/bin/claude"
  if [[ -e "$brew_claude" || -L "$brew_claude" ]] && ! brew list --cask claude-code >/dev/null 2>&1; then
    mkdir -p "$BACKUP_DIR"
    if mv "$brew_claude" "$BACKUP_DIR/claude"; then
      warning "Moved a non-cask claude at $brew_claude aside so the cask can install (backed up)"
    else
      warning "Could not move $brew_claude; the claude-code cask may fail to install"
    fi
  fi
fi

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
  elif [[ -L "$target" ]]; then
    # An existing symlink is someone else's config -- stow, chezmoi, another
    # dotfiles repo. ln -sfn would replace it with nothing recorded, so note
    # where it pointed. The link itself is cheap to recreate; knowing the
    # target is the part that is lost otherwise.
    local current rel
    current="$(readlink "$target")"
    if [[ "$current" != "$source" ]]; then
      rel="${target#"$HOME"/}"
      mkdir -p "$BACKUP_DIR"
      printf '%s -> %s\n' "$rel" "$current" >> "$BACKUP_DIR/replaced-symlinks.txt"
    fi
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

# iTerm2 picks up dynamic profiles automatically (colors + font, no manual import)
if [[ "$OS" == "macos" ]]; then
  link "$DOTFILES_DIR/iterm2/profile.json" "$HOME/Library/Application Support/iTerm2/DynamicProfiles/dotfiles.json"
fi

# bin/ scripts onto PATH (gifenc needs ffmpeg, which only personal mode installs)
mkdir -p "$HOME/.local/bin"
for script in "$DOTFILES_DIR"/bin/*; do
  [[ -f "$script" ]] || continue
  name="$(basename "$script")"
  # gifenc needs ffmpeg, which only personal mode installs. Switching
  # personal -> corporate must remove the link, not just skip creating it,
  # or a live symlink to a broken script survives the mode change.
  if [[ "$MODE" == "corporate" && "$name" == "gifenc" ]]; then
    [[ -L "$HOME/.local/bin/$name" ]] && rm -f "$HOME/.local/bin/$name"
    continue
  fi
  ln -sfn "$script" "$HOME/.local/bin/$name"
done
success "Linked bin/ scripts to ~/.local/bin"

if [[ -f "$HOME/.gitignore_global" ]]; then
  warning "The old ~/.gitignore_global is no longer used; global ignores now live in ~/.config/git/ignore"
fi

# Only claim a backup when something other than the symlink ledger is in there.
if [[ -d "$BACKUP_DIR" ]] && [[ -n "$(find "$BACKUP_DIR" -mindepth 1 ! -name 'replaced-symlinks.txt' -print -quit)" ]]; then
  info "Previous configs backed up to $BACKUP_DIR"
fi
[[ -f "$BACKUP_DIR/replaced-symlinks.txt" ]] && \
  info "Replaced symlinks recorded in $BACKUP_DIR/replaced-symlinks.txt"

# ----------------------------------------
# Nerd Font (Linux; macOS gets it as a cask)
# ----------------------------------------

if [[ "$OS" == "linux" ]] && command -v fc-cache >/dev/null 2>&1; then
  FONT_DIR="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
  # Check for actual font files, not just the directory: if a previous run
  # created the directory and then failed to extract, testing -d alone would
  # skip the install forever and leave the prompt rendering as tofu.
  if ! compgen -G "$FONT_DIR/*.ttf" >/dev/null 2>&1; then
    info "Installing JetBrains Mono Nerd Font..."
    font_tmp="$(mktemp -d)"
    if curl -fsSL -o "$font_tmp/JetBrainsMono.tar.xz" \
        "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz" \
        && mkdir -p "$FONT_DIR" \
        && tar -xJf "$font_tmp/JetBrainsMono.tar.xz" -C "$FONT_DIR"; then
      fc-cache -f "$FONT_DIR" >/dev/null || true
      success "Nerd Font installed"
    else
      warning "Font download failed; install a Nerd Font manually for prompt icons"
    fi
    rm -rf "$font_tmp"
  else
    success "Nerd Font already installed"
  fi
fi

# Point the terminal at the font. Deliberately outside the fc-cache check above:
# installing font files and configuring the terminal are independent, and
# fontconfig is only apt-installed when Homebrew was missing -- so a machine
# that already had brew would otherwise never get its terminal configured.
# Exit code matters here: 0 configured, 1 failed, 2 nothing to configure.
# Treating any non-failure as success reported "Terminal font is configured" on
# headless boxes that had printed "No supported terminal found" moments earlier.
TERMINAL_CONFIGURED=0
if [[ "$OS" == "linux" && -x "$DOTFILES_DIR/linux-terminal.sh" ]]; then
  "$DOTFILES_DIR/linux-terminal.sh" && terminal_rc=0 || terminal_rc=$?
  case "$terminal_rc" in
    0) TERMINAL_CONFIGURED=1 ;;
    2) : ;;   # nothing to configure; next-steps tells the user what to set
    *) warning "Terminal font setup failed; set it manually" ;;
  esac
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

# Test for the .git directory, not the directory itself: an interrupted clone
# leaves an empty or partial directory that would skip this forever, the same
# trap as the nerd font check. bootstrap.sh already tests .git this way.
if [[ ! -d "$HOME/.tmux/plugins/tpm/.git" ]]; then
  info "Installing tmux plugin manager..."
  # Move a non-git tpm aside rather than deleting it: it may be a tarball or
  # package install rather than a half-finished clone. Guarded like the clone
  # below -- an unguarded mv would abort the installer under set -e before
  # Neovim, the extras and chsh.
  tpm_ready=1
  if [[ -e "$HOME/.tmux/plugins/tpm" ]]; then
    mkdir -p "$BACKUP_DIR/.tmux/plugins"
    if mv "$HOME/.tmux/plugins/tpm" "$BACKUP_DIR/.tmux/plugins/tpm"; then
      warning "Moved an existing non-git tpm to $BACKUP_DIR/.tmux/plugins/tpm"
    else
      # The clone would fail anyway with the directory still in place, so skip
      # it rather than emit a second, more confusing error.
      warning "Could not move the existing tpm aside; leaving it in place"
      tpm_ready=0
    fi
  fi
  # Guarded like every other network call here: a proxy or a GitHub blip should
  # not abort the installer before mise, Neovim, the extras and chsh.
  if [[ "$tpm_ready" == 1 ]]; then
    if git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"; then
      success "TPM installed (prefix + I inside tmux installs plugins)"
    else
      warning "Could not clone TPM; tmux will install it on first launch"
    fi
  fi
fi

if command -v tldr >/dev/null 2>&1; then
  info "Updating tldr cache..."
  tldr --update >/dev/null 2>&1 && success "tldr cache updated"
fi

# Import pre-existing zsh history so Ctrl+R is useful from the first session,
# instead of asking the user to run this themselves. Only into an empty atuin
# database: import does not deduplicate, so on a rerun it would double every
# entry. A machine with no history file yet has nothing to import -- skip
# silently rather than warn about a non-problem.
if command -v atuin >/dev/null 2>&1; then
  hist_file="${HISTFILE:-$HOME/.zsh_history}"
  if [[ -f "$hist_file" ]] && [[ -z "$(atuin history list 2>/dev/null | head -n 1)" ]]; then
    info "Importing shell history into atuin..."
    if atuin import zsh >/dev/null 2>&1; then
      success "Shell history imported"
    else
      warning "History import failed; run 'atuin import zsh' manually"
    fi
  fi
fi

# Runtimes for personal machines; corporate boxes may have their own policy
if [[ "$MODE" == "personal" ]] && command -v mise >/dev/null 2>&1; then
  info "Installing node (lts) and go (latest) via mise..."
  if mise use -g node@lts >/dev/null 2>&1; then success "node ready"; else warning "node install via mise failed"; fi
  if mise use -g go@latest >/dev/null 2>&1; then success "go ready"; else warning "go install via mise failed"; fi
fi

# Pre-install neovim plugins (exact lockfile versions) and language servers
# so the first launch is instant instead of a plugin-download storm
if command -v nvim >/dev/null 2>&1; then
  info "Preparing Neovim plugins and language servers (can take a few minutes)..."
  nvim --headless "+Lazy! restore" +qa >/dev/null 2>&1 \
    || warning "Neovim plugin restore failed; plugins will install on first launch"
  if command -v mise >/dev/null 2>&1; then
    mise x -- nvim --headless "+MasonToolsInstallSync" +qa >/dev/null 2>&1 \
      || warning "Some language servers failed to install; they will retry on demand"
  else
    nvim --headless "+MasonToolsInstallSync" +qa >/dev/null 2>&1 \
      || warning "Some language servers failed to install; they will retry on demand"
  fi
  success "Neovim ready"
fi

# Personal mode on macOS installs Claude Code, gcloud and the 1Password CLI as
# casks. Those lines are stripped on Linux, so install the same tools from the
# vendors' Linux channels to keep the two platforms at parity.
if [[ "$MODE" == "personal" && "$OS" == "linux" && -x "$DOTFILES_DIR/linux-extras.sh" ]]; then
  info "Installing personal-mode tools that are casks on macOS..."
  "$DOTFILES_DIR/linux-extras.sh" || warning "Some Linux extras failed; see the output above"
fi

if [[ "$WITH_MACOS_DEFAULTS" == 1 && "$OS" == "macos" ]]; then
  info "Applying macOS defaults..."
  if "$DOTFILES_DIR/macos.sh"; then success "macOS defaults applied"; else warning "macos.sh failed"; fi
fi

if [[ "$WITH_MAC_KEYS" == 1 && "$OS" == "linux" ]]; then
  # Toshy: mac-style keyboard shortcuts (github.com/RedBearAK/toshy)
  if [[ -t 0 ]]; then
    info "Installing Toshy (mac-style keyboard shortcuts)..."
    [[ -d "$HOME/toshy-src" ]] || git clone --depth 1 https://github.com/RedBearAK/toshy.git "$HOME/toshy-src"
    (cd "$HOME/toshy-src" && ./setup_toshy.py install) \
      || warning "Toshy install failed; run it manually from ~/toshy-src"
  else
    warning "Toshy's installer is interactive; run: git clone https://github.com/RedBearAK/toshy.git && cd toshy && ./setup_toshy.py install"
  fi
fi

# $SHELL reflects the shell that happens to be running, which is not the login
# shell inside editors, CI or a nested bash. Read the account record instead --
# getent on Linux, dscl on macOS, which has no getent. Both are guarded because
# a missing command would otherwise take the whole script down under `set -e`.
LOGIN_SHELL=""
if command -v getent >/dev/null 2>&1; then
  LOGIN_SHELL="$(getent passwd "$(id -un)" 2>/dev/null | cut -d: -f7)" || LOGIN_SHELL=""
elif command -v dscl >/dev/null 2>&1; then
  LOGIN_SHELL="$(dscl . -read "/Users/$(id -un)" UserShell 2>/dev/null | awk '{print $2}')" || LOGIN_SHELL=""
fi
LOGIN_SHELL="${LOGIN_SHELL:-$SHELL}"
if [[ "$LOGIN_SHELL" == *zsh ]]; then
  success "Login shell already zsh"
elif command -v zsh >/dev/null 2>&1; then
  info "Setting zsh as default shell (currently $LOGIN_SHELL)..."
  chsh -s "$(command -v zsh)" || warning "Could not change the default shell; run chsh manually"
else
  warning "zsh is not installed; login shell left as $LOGIN_SHELL"
fi

# ----------------------------------------
# Git identity (kept out of the repo)
# ----------------------------------------

# Taken from GitHub rather than typed in: a browser login via gh, then the
# account's name and email flow into ~/.gitconfig.local. Deliberately the last
# step of the run, so the hand-off to the browser comes after the long package
# installs instead of being buried in the middle of them. The old manual
# prompt survives as the fallback for a declined login, a failed one, or a
# machine where GitHub is not the forge.
# An existing file does not prove a usable identity: the old prompt accepted
# an empty answer, and a machine with `name =` blank cannot create any commit
# -- not even the autostash commit a bootstrap pull needs, which is how one
# machine got stuck on a stale clone. Validate the two keys, not the file.
git_identity_ok() {
  [[ -n "$(git config --file "$HOME/.gitconfig.local" user.name 2>/dev/null)" ]] \
    && [[ -n "$(git config --file "$HOME/.gitconfig.local" user.email 2>/dev/null)" ]]
}

if git_identity_ok; then
  success "Git identity already configured (~/.gitconfig.local)"
else
  if [[ -f "$HOME/.gitconfig.local" ]]; then
    warning "Existing ~/.gitconfig.local is missing a name or email; repairing it"
  fi
  gh_authed=0
  if command -v gh >/dev/null 2>&1; then
    if gh auth status >/dev/null 2>&1; then
      # Already signed in (a rerun, or gh set up beforehand) -- no prompt, the
      # identity can be derived straight away.
      gh_authed=1
    elif have_tty; then
      echo ""
      info "Git identity can be taken from your GitHub account."
      read -rp "Log in to GitHub in the browser? [Y/n]: " gh_choice </dev/tty
      # Anything that is not an explicit no counts as the default yes
      if [[ ! "$gh_choice" =~ ^[Nn] ]]; then
        # gh prompts on its own stdin, which on the piped bootstrap path is
        # the script itself -- point it at the terminal like every prompt
        # here. stdout stays untouched: gh prints the one-time code there.
        if gh auth login --hostname github.com --git-protocol https --web </dev/tty; then
          gh_authed=1
        else
          warning "GitHub login failed or was cancelled; falling back to the manual prompt"
        fi
      fi
    fi
  fi

  if [[ "$gh_authed" == 1 ]]; then
    # Let git itself push and pull with gh's credentials, not just the API
    gh auth setup-git >/dev/null 2>&1 || true
    # `// .login` alone is not enough: an unset display name is null, but a
    # cleared one can be the empty string, and either should fall back.
    git_name="$(gh api user --jq 'if (.name // "") == "" then .login else .name end' 2>/dev/null)" || git_name=""
    # A profile with a hidden email gets the account's noreply address --
    # GitHub links it to the account all the same, and it is the address the
    # "Keep my email addresses private" push protection expects in commits.
    git_email="$(gh api user --jq '.email // "\(.id)+\(.login)@users.noreply.github.com"' 2>/dev/null)" || git_email=""
    if [[ -n "$git_name" && -n "$git_email" ]]; then
      # git config, not a printf of the whole file: a repair must not wipe
      # whatever else the user has added to ~/.gitconfig.local over time.
      git config --file "$HOME/.gitconfig.local" user.name "$git_name"
      git config --file "$HOME/.gitconfig.local" user.email "$git_email"
      success "Git identity from GitHub: $git_name <$git_email>"
    else
      warning "Could not read your GitHub profile; falling back to the manual prompt"
    fi
  fi

  if ! git_identity_ok; then
    # Read from /dev/tty, not stdin: on the piped bootstrap path stdin is the
    # script itself. Without this the prompt is skipped, no ~/.gitconfig.local
    # is written, and since git/.gitconfig includes it unconditionally git
    # falls back to a guessed user@hostname -- committing under a wrong
    # identity rather than failing loudly.
    if have_tty; then
      # Loop until non-empty: accepting a blank answer here is what produced
      # the half-written identity this section now has to repair.
      git_name=""
      while [[ -z "$git_name" ]]; do
        read -rp "Git name: " git_name </dev/tty
      done
      git_email=""
      while [[ -z "$git_email" ]]; do
        if [[ "$MODE" == "corporate" ]]; then
          read -rp "Git email (use your WORK email): " git_email </dev/tty
        else
          read -rp "Git email: " git_email </dev/tty
        fi
      done
      git config --file "$HOME/.gitconfig.local" user.name "$git_name"
      git config --file "$HOME/.gitconfig.local" user.email "$git_email"
      success "Wrote ~/.gitconfig.local"
    else
      warning "Non-interactive shell: create ~/.gitconfig.local with your [user] name/email"
    fi
  fi
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
  echo "  2. iTerm2: Settings > Profiles > 'dotfiles' > Other Actions > Set as Default"
  echo "     (Dracula+ colors and the nerd font are baked into the profile)"
elif [[ "$TERMINAL_CONFIGURED" == 1 ]]; then
  echo "  2. Terminal font is configured. Quit the terminal completely and reopen"
  echo "     -- a new tab is not enough, since a running terminal caches the font"
  echo "     list from startup."
else
  echo "  2. Set your terminal font to JetBrainsMono Nerd Font"
fi
if [[ "$MODE" == "personal" ]]; then
  # Only name tools that are actually here: on Linux the apt-based ones are
  # skipped when sudo is unavailable, and telling someone to run a command
  # they do not have is worse than saying nothing.
  signins=()
  { command -v claude >/dev/null 2>&1 || [[ -x "$HOME/.local/bin/claude" ]]; } && signins+=("claude")
  command -v gcloud >/dev/null 2>&1 && signins+=("gcloud auth login")
  command -v op     >/dev/null 2>&1 && signins+=("op signin")
  if [[ ${#signins[@]} -gt 0 ]]; then
    # "${arr[*]}" joins on the FIRST character of IFS only, so IFS=' / ' gave
    # "claude gcloud auth login op signin" -- unreadable, since the entries
    # themselves contain spaces.
    printf -v joined '%s / ' "${signins[@]}"
    echo "  3. Sign in:             ${joined% / }"
  fi
  if [[ "$OS" == "linux" ]]; then
    echo "     Claude desktop app: https://code.claude.com/docs/en/desktop-linux"
  fi
fi
echo ""
