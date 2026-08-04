# ========================================
# Environment
# ========================================

export XDG_CONFIG_HOME="$HOME/.config"
export EZA_CONFIG_DIR="$XDG_CONFIG_HOME/eza"
export BAT_THEME="Catppuccin Mocha"
export EDITOR="nvim"

# Colored man pages via bat
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# Local binaries (also where dotfiles bin/ scripts are linked)
export PATH="$HOME/.local/bin:$PATH"

# Catppuccin Mocha colors for fzf (github.com/catppuccin/fzf)
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a \
--color=border:#6c7086,label:#cdd6f4"

# ========================================
# Plugins (antidote)
# ========================================

source "$(brew --prefix)/opt/antidote/share/antidote/antidote.zsh"
antidote load

# ========================================
# Tool integrations
# ========================================

# fzf keybindings (Ctrl+T files, Alt+C dirs)
source <(fzf --zsh)

# atuin shell history (takes over Ctrl+R; keeps arrow keys as-is)
command -v atuin >/dev/null && eval "$(atuin init zsh --disable-up-arrow)"

# zoxide smart directory jumping (z / zi)
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

# mise polyglot version manager (node, python, etc.)
command -v mise >/dev/null && eval "$(mise activate zsh)"

# ========================================
# Aliases
# ========================================

alias ls="eza --icons"
alias ll="eza --icons -l"
alias la="eza --icons -la"
alias lt="eza --icons --tree --level=2"
alias cat="bat"
alias lg="lazygit"

# Update everything: Homebrew, App Store apps, macOS
alias osup="brew update && brew upgrade && brew cleanup && mas upgrade && sudo softwareupdate -i --restart"

# ========================================
# Machine-specific paths (loaded only if present)
# ========================================

# Android SDK
if [[ -d "$HOME/Library/Android/sdk" ]]; then
  export ANDROID_HOME="$HOME/Library/Android/sdk"
  export PATH="$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools"
fi

# Android Studio bundled JDK
if [[ -d "/Applications/Android Studio.app/Contents/jbr/Contents/Home" ]]; then
  export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
  export PATH="$JAVA_HOME/bin:$PATH"
fi

# ========================================
# Secrets & local overrides (never committed)
# ========================================

# API keys and tokens live in ~/.secrets.env (chmod 600)
[[ -f "$HOME/.secrets.env" ]] && source "$HOME/.secrets.env"

# Machine-specific config that doesn't belong in the repo
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# ========================================
# Prompt
# ========================================

eval "$(starship init zsh)"
