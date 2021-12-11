# Set of my dotfiles and recipes for MAC OS

> Please be careful. Issue this commands and install this software only if you fully understand what you are doing. You can accidently brake your prodution enviroment (for example by replacing python version or by overwriting your $PATH).

> **Make a copy of your home directory and "." (dot) config files, for example .zshrc .vimrc and .tmux.conf**

## Prerequisites 
1. [Homebrew](https://brew.sh/) - because you work on your Mac, right?
2. [iTerm2](https://www.iterm2.com/) - because it is awesome and also has a 256-color support.


## Installation
**Step zero**
Open iTerm and use it from now on ;)

**Python first:**
(currently lastest supported version by pyenv is 3.8.5, but you better check it by 'pyenv install -l')

    brew install pyenv
    pyenv install 3.8.5
    pyenv global 3.8.5
    pyenv version

*Note: pyenv will be enabled later by command in your .zshrc , so do not try to check python version now.*

**Xcode** 

    xcode-select --install

**Packages through Brew**     
        
    brew install zsh
    brew install autojump FZF vim wget git tmux zsh-autosuggestions zsh-syntax-highlighting

**Vundle package manager for vim**
    
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
      
**OhMyZsh**
    
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
        
**[powerlevel10k](https://github.com/romkatv/powerlevel10k) theme for OhMyZsh**

    git clone https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k


**Now get and then copy .dotfiles (this will overwrite your current files, so be careful)**

    git clone https://github.com/ikwach/dotfiles.git
    cp dotfiles/.vimrc ~/
    cp dotfiles/.zshrc ~/
    cp dotfiles/.tmux.conf ~/
 
**Now it's time to make a plugin install using Vundle. You can see some errors during this step. It is normal.**

Open file by vim, you can see some errors, it's fine.

    vim ~/.vimrc

While open type:
    
    :source %

And then (this procedure will take some time)

    :PluginInstall

After all done, just close vim with standart **:q**'s

**Install fzf**

    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install

**Final step**

Now finally close all iTerm windows and start a new one. This should trigger powerlevel10k setup.
If not maybe you are still using bash instead of zsh shell, so try typing **zsh**
You can always restart powerlevel10k setup by typing **p10k configure**




