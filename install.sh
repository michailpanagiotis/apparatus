sudo apt-get install vim-nox git tmux
cd $HOME/.apparatus/
git submodule init
git submodule update
ln -s $HOME/.apparatus/vim/vimrcs/vimrc.base $HOME/.vimrc
ln -s $HOME/.apparatus/vim $HOME/.vim
ln -s $HOME/.apparatus/tmux/tmux.conf $HOME/.tmux.conf
ln -s $HOME/.apparatus/git/gitconfig $HOME/.gitconfig
