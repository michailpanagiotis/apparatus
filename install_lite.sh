#!/bin/bash

INSTALL_BASE=1

if [ "${INSTALL_BASE}" -eq "1" ]; then
  echo === Installing base...
  apt-get update
  apt-get --assume-yes install curl fzf git ripgrep ncdu build-essential
  echo === Installing base...done!
fi

if [ ! -d "$HOME/.apparatus" ]
then
    git clone https://github.com/michailpanagiotis/apparatus $HOME/.apparatus
    if [ ! -f "$HOME/.zshrc" ]
    then
        ln -s $HOME/.apparatus/.zshrc $HOME/.zshrc
    fi

    if [ ! -f "$HOME/.gitconfig" ]
    then
        ln -s $HOME/.apparatus/git/gitconfig $HOME/.gitconfig
    fi

    if [ ! -d "$HOME/.config/nvim" ]
    then
        ln -s $HOME/.apparatus/nvim $HOME/.config/nvim
    fi
fi

# NEOVIM
if ! command -v nvim &> /dev/null
then
    wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.deb
    apt install ./nvim-linux64.deb
    rm ./nvim-linux64.deb
    # SET NVIM AS DEFAULT
    update-alternatives --install /usr/bin/ex ex $(which nvim) 110
    update-alternatives --install /usr/bin/vi vi $(which nvim) 110
    update-alternatives --install /usr/bin/view view $(which nvim) 110
    update-alternatives --install /usr/bin/vim vim $(which nvim) 110
    update-alternatives --install /usr/bin/vimdiff vimdiff $(which nvim) 110
    update-alternatives --set ex $(which nvim)
    update-alternatives --set vi $(which nvim)
    update-alternatives --set view $(which nvim)
    update-alternatives --set vim $(which nvim)
    update-alternatives --set vimdiff $(which nvim)
fi

# ZSH
if ! command -v zsh &> /dev/null
then
    apt-get --assume-yes install zsh
    if [ ! -d "$HOME/.oh-my-zsh" ]
    then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        PRE_ZSHRC=$HOME/.zshrc.pre-oh-my-zsh
        if test -f "$PRE_ZSHRC"; then
            rm $PRE_ZSHRC
        fi
    fi
fi
