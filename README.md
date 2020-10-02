# Set of my dotfiles and recipes for MAC OS

> Please be careful. Issue this commands and install this software only if you fully understand what you are doing. You can accidently brake your prodution enviroment (for example by replacing python version or by overwriting your $PATH).

> **Make a copy of your home directory "." (dot) config files, for example .zshrc or .vimrc etc.**

## Prerequisites 
1. [Homebrew](https://brew.sh/)
2. [iTerm2](https://www.iterm2.com/)


## Installation

**Python first:**
(currently lastest supported version by pyenv is 3.8.5, but you better check it)

    brew install pyenv
    pyenv install 3.8.5
    pyenv global 3.8.5
    pyenv version

*Note: pyenv will be enabled later by command in your .zshrc , so do not try to check python version now.*

**Packages through Brew**     
        
    brew install zsh
    brew install autojump FZF vim wget git tmux zsh-autosuggestions zsh-syntax-highlighting

**Vundle package manager for vim**
    
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
      
**OhMyZsh**
    
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
        
**[powerlevel10k](https://github.com/romkatv/powerlevel10k) theme for OhMyZsh**

    git clone https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k



echo "Now copy .vimrc , open it and type"
echo ":source %"
echo ":PluginInstall"




git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install






