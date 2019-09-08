# dotfiles
Set of my dotfiles and recipes

Own coding skills


brew install zsh
brew install tmux
brew install autojump
brew install FZF

sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

Add plugins to your shell by adding the name of the plugin to the plugin array in your .zshrc.
plugins=(git colored-man colorize pip python brew osx zsh-syntax-highlighting)
You'll find a list of all plugins on the Oh My Zsh Wiki. Note that adding plugins can cause your shell startup time to increase.

Themes
Changing theme is as simple as changing a string in your configuration file. The default theme is robbyrussell. Just change that value to change theme, and don't forget to apply your changes.
ZSH_THEME=pygmalion


git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim


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




