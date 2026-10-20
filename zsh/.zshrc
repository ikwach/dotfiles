# ========================================
# Environment
# ========================================

# Homebrew on Linux: most Linux terminals start non-login shells, which
# skip ~/.zprofile, so put brew on PATH here as well
if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

export XDG_CONFIG_HOME="$HOME/.config"
export EZA_CONFIG_DIR="$XDG_CONFIG_HOME/eza"
export BAT_THEME="Catppuccin Mocha"
export EDITOR="nvim"

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
# History
# ========================================

# macOS ships SAVEHIST=1000, which starves zsh-autosuggestions
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY      # write and import history as commands run
setopt HIST_IGNORE_DUPS   # skip consecutive duplicates
setopt HIST_IGNORE_SPACE  # commands starting with a space stay out

# ========================================
# Line editing
# ========================================

# zsh drops into vi mode whenever EDITOR or VISUAL contains "vi", which nvim
# does; pin the usual emacs keys (Ctrl+A/E/K/U/W, Alt+B/F) explicitly
bindkey -e

# ========================================
# Plugins (antidote)
# ========================================

# Everything below is guarded so the shell starts cleanly even before
# install.sh has run (or on machines where some tools are blocked).
if command -v brew >/dev/null; then
  # $HOMEBREW_PREFIX is exported by the shellenv eval above; `brew --prefix`
  # would fork a process on every shell start to learn the same thing.
  ANTIDOTE_ZSH="${HOMEBREW_PREFIX:-$(brew --prefix)}/opt/antidote/share/antidote/antidote.zsh"
  if [[ -r "$ANTIDOTE_ZSH" ]]; then
    source "$ANTIDOTE_ZSH"
    antidote load
  fi
  unset ANTIDOTE_ZSH
fi

# ========================================
# Tool integrations
# ========================================

# fzf keybindings (Ctrl+T files, Alt+C dirs)
command -v fzf >/dev/null && source <(fzf --zsh)

# atuin shell history (takes over Ctrl+R; keeps arrow keys as-is)
command -v atuin >/dev/null && eval "$(atuin init zsh --disable-up-arrow)"

# zoxide smart directory jumping (z / zi)
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

# mise polyglot version manager (node, python, etc.)
if command -v mise >/dev/null; then
  eval "$(mise activate zsh)"

  # mise re-runs `mise hook-env` before every prompt so edits to .nvmrc or
  # mise.toml apply without a cd, but starting mise costs ~150ms on a loaded
  # machine. Keep only its cd hook, plus a rerun after any `mise` command so
  # `mise use` / `mise install` still apply at once; after editing those files
  # by hand, `cd .` picks the change up.
  _mise_preexec() { [[ $1 == mise(| *) ]] && _mise_rerun=1 }
  _mise_precmd() { (( _mise_rerun )) && { _mise_rerun=0; _mise_hook --reason precmd } }
  add-zsh-hook -d precmd _mise_hook_precmd
  add-zsh-hook preexec _mise_preexec
  add-zsh-hook precmd _mise_precmd
fi

# ========================================
# Aliases
# ========================================

if command -v eza >/dev/null; then
  alias ls="eza --icons=auto"
  alias ll="eza --icons=auto -l"
  alias la="eza --icons=auto -la"
  alias lt="eza --icons=auto --tree --level=2"
fi

if command -v bat >/dev/null; then
  alias cat="bat"
  # Colored man pages via bat
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

command -v lazygit >/dev/null && alias lg="lazygit"

# Update everything: Homebrew, plus App Store apps and the OS itself on macOS
if [[ "$OSTYPE" == darwin* ]]; then
  alias osup="brew update && brew upgrade && brew cleanup && mas upgrade && sudo softwareupdate -i -a --restart"
else
  alias osup="brew update && brew upgrade && brew cleanup && sudo apt-get update && sudo apt-get upgrade -y"
fi

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

if command -v starship >/dev/null; then
  eval "$(starship init zsh)"

  # starship's init has zsh run starship from inside PROMPT and RPROMPT each time
  # the prompt is drawn. A Ctrl+C during that render kills starship, and zsh then
  # gives up on the prompt: the left side comes out blank and RPROMPT's raw
  # `$(starship prompt --right ...)` source is printed in its place. Rendering in
  # precmd instead is safe, because zsh drops an interrupt raised there and keeps
  # showing the last prompt that did render.
  _starship_render() {
    local p
    p=$(starship prompt --terminal-width="$COLUMNS" --keymap="${KEYMAP:-}" \
      --status="${STARSHIP_CMD_STATUS:-}" --pipestatus="${STARSHIP_PIPE_STATUS[*]:-}" \
      --cmd-duration="${STARSHIP_DURATION:-}" --jobs="$STARSHIP_JOBS_COUNT") &&
      _starship_prompt=$p
  }
  add-zsh-hook precmd _starship_render
  # Expanded at draw time rather than assigned the text: iTerm2's shell
  # integration wraps PROMPT with its marks in a precmd that runs before ours
  PROMPT='$_starship_prompt'
  # starship.toml has no right_format, so this only cost an extra starship run
  # per prompt; render it in _starship_render too if one is ever added
  RPROMPT=
  # Only fires in vi mode (bindkey -v in place of -e above): re-render so the
  # prompt character still follows the keymap
  starship_zle-keymap-select() {
    _starship_render
    zle reset-prompt
  }
fi
