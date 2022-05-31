#!/bin/bash
# exit when any command fails
set -e

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac

cd $HOME/.apparatus/

if test -f "jetbrains_mono.zip"; then
    echo "JetBrains Mono exists"
else
    curl -Ls -o jetbrains_mono.zip https://download-cdn.jetbrains.com/fonts/JetBrainsMono-2.242.zip?_gl=1*uv3l58*_ga*MjAzODU5MDk1LjE2NTM1NzczMTg.*_ga_9J976DJZ68*MTY1MzU3NzMxNi4xLjEuMTY1MzU3NzMyOC4w&_ga=2.27630709.816184028.1653577318-203859095.1653577318
    unzip -o jetbrains_mono.zip -d ~/.local/share/fonts
    fc-cache -f -v
fi

echo 'Setting config for vim'
rm -rf $HOME/.vimrc
ln -s $HOME/.apparatus/vim/vimrcs/vimrc.base $HOME/.vimrc
rm -rf $HOME/.vim
ln -s $HOME/.apparatus/vim $HOME/.vim
rm -rf $HOME/.config/nvim
ln -s $HOME/.apparatus/nvim/ $HOME/.config/
echo 'Setting config for git'
rm -rf $HOME/.gitconfig
ln -s $HOME/.apparatus/git/gitconfig $HOME/.gitconfig
echo 'Setting config for kitty'
rm -rf $HOME/.config/kitty
ln -s $HOME/.apparatus/kitty/ $HOME/.config/

if [ "$machine" = "Mac" ]; then
    ./install_mac.sh
else
    ./install_linux.sh
fi
