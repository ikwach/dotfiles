# Set of my dotfiles and recipes for MAC OS

> Please be careful. Issue this commands and install this software only if you fully understand what you are doing. You can accidently brake your prodution enviroment (for example by replacing python version or by overwriting your $PATH)

## Prerequisites 
1. curl
1. wget
1. git
1. [Homebrew](https://brew.sh/)
1. Full version of vim (not default one)
1. zsh

## Installation
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

brew install tmux autojump FZF python vim

sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

echo "Now copy .vimrc , open it and type"
echo ":source %"
echo ":PluginInstall"


Add plugins to your shell by adding the name of the plugin to the plugin array in your .zshrc.
plugins=(git colored-man colorize pip python brew osx zsh-syntax-highlighting)
You'll find a list of all plugins on the Oh My Zsh Wiki. Note that adding plugins can cause your shell startup time to increase.

Themes
Changing theme is as simple as changing a string in your configuration file. The default theme is robbyrussell. Just change that value to change theme, and don't forget to apply your changes.
ZSH_THEME=pygmalion


git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install


vi ~/.zshrc

plugins=(
  git
  bundler
  dotenv
  osx
  rake
  rbenv
  ruby
  fzf
  web-search 
)

ZSH_THEME="powerlevel10k/powerlevel10k" 




