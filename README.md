Apparatus
=========

A basic configuration for workstations using *vim*, *tmux* and *git*.

Before Installing
-----------------
Before installation backup your old configuration:

 - $HOME/.vim folder
 - $HOME/.vimrc
 - $HOME/.tmux.conf
 - $HOME/.gitconfig

Installation
------------

Obtain the tools:

    sudo apt-get install vim git tmux

Clone the repository:

    git clone https://github.com/michailpanagiotis/vimconfig.git $HOME/.myconfig


Fetch the submodules:

    cd $HOME/.myconfig/
    git submodule init
    git submodule update

Set the configuration for *vim*:

    ln -s $HOME/.myconfig/vim/vimrcs/vimrc.base $HOME/.vimrc
    ln -s $HOME/.myconfig/vim $HOME/.vim

Set the configuration for *tmux*:

    ln -s $HOME/.myconfig/tmux/tmux.conf $HOME/.tmux.conf

Set the configuration for *git*:

    ln -s $HOME/.myconfig/git/gitconfig $HOME/.gitconfig
