vimconfig
=========

The vim configuration and plugins we use at work.


Installation
------------

Before installation backup your old vim configuration (~/.vim folder and ~/.vimrc).

    git clone https://github.com/michailpanagiotis/vimconfig.git $HOME/.vim
    ln -s $HOME/.vim/vimrcs/vimrc.base $HOME/.vimrc
    cd $HOME/.vim/
    git submodule init
    git submodule update

