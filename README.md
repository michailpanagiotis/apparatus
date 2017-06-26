Apparatus
=========

A basic configuration for workstations using *vim*, *tmux* and *git*.

Before Installing
-----------------
Before installation backup your old configuration:

     $HOME/.vim
     $HOME/.vimrc
     $HOME/.tmux.conf
     $HOME/.gitconfig

Installation
------------

Obtain the tools:

    sudo apt-get install vim-nox git tmux

Clone the repository:

    git clone https://github.com/michailpanagiotis/vimconfig.git $HOME/.apparatus


Fetch the submodules:

    cd $HOME/.apparatus/
    git submodule init
    git submodule update

Set the configuration for *vim*:

    ln -s $HOME/.apparatus/vim/vimrcs/vimrc.base $HOME/.vimrc
    ln -s $HOME/.apparatus/vim $HOME/.vim

Set the configuration for *git*:

    ln -s $HOME/.apparatus/git/gitconfig $HOME/.gitconfig

Set the configuration for *tmux*:

    ln -s $HOME/.apparatus/tmux/tmux.conf $HOME/.tmux.conf

Set the tmux plugin manager:

    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

After opening tmux just install all plugins referenced in the .tmux.config by pressing:

    Ctrl-a I
