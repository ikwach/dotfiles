# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
autoload -Uz compinit
compinit
# source antidote
source $(brew --prefix)/opt/antidote/share/antidote/antidote.zsh
# initialize plugins statically with ${ZDOTDIR:-~}/.zsh_plugins.txt
antidote load
# enabling FZF integration for CTRL-R and other powerful features
source <(fzf --zsh)

# Android SDK
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"

#. "$HOME/.local/bin/env"

alias osup="echo 'Updating Homebrew...'; brew update; echo 'Upgrading outdated packages...'; brew upgrade; echo 'Cleaning up...'; brew cleanup; echo 'Done!' ; echo 'Upgrading mac apps...'; mas upgrade; echo 'Done!'; echo 'Updating macos and restarting if needed...'; sudo softwareupdate -i --restart ; echo 'Done!'"
export OPENAI_API_KEY="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"
