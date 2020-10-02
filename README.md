# Set of my dotfiles and recipes for MAC OS

> Please be careful. Issue this commands and install this software only if you fully understand what you are doing. You can accidently brake your prodution enviroment (for example by replacing python version or by overwriting your $PATH)

## Prerequisites 
1. [Homebrew](https://brew.sh/)
2. [iTerm2](https://www.iterm2.com/)


## Installation
brew install tmux autojump FZF vim wget git zsh zsh-autosuggestions zsh-syntax-highlighting

Python first:

brew install pyenv
pyenv install 3.8.5 -- LATEST PLZ
pyenv global 3.8.5 -- LATEST PLZ
pyenv version

echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ~/.zshrc
After that command, our dotfile (.zshrc for zsh or .bash_profile for Bash) should look include these lines:

if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

Check:

which python

python -V

pip -V


=========================
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
git clone https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k


======




git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

echo "Now copy .vimrc , open it and type"
echo ":source %"
echo ":PluginInstall"

echo "Now copy .vimrc , open it and type"
echo ":source %"
echo ":PluginInstall"


git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf

~/.fzf/install






