sudo apt-get install curl git flatpak

echo 'Please, manually install kitty and kinto'

flatpak install --noninteractive bitwarden
flatpak install --noninteractive slack
flatpak install --noninteractive zoom
flatpak install --noninteractive spotify
flatpak install --noninteractive brave

cd $HOME/.apparatus/

if test -f "nvim.appimage"; then
    echo "nvim.appimage exists."
else
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
    chmod u+x nvim.appimage
fi

if test -f "/usr/bin/nvim"; then
    echo "global nvim exists."
else
    sudo ln -s $HOME/.apparatus/nvim.appimage /usr/bin/nvim
fi

CUSTOM_NVIM_PATH=/usr/bin/nvim
# Set the above with the correct path, then run the rest of the commands:
set -u
sudo update-alternatives --install /usr/bin/ex ex "${CUSTOM_NVIM_PATH}" 110
sudo update-alternatives --install /usr/bin/vi vi "${CUSTOM_NVIM_PATH}" 110
sudo update-alternatives --install /usr/bin/view view "${CUSTOM_NVIM_PATH}" 110
sudo update-alternatives --install /usr/bin/vim vim "${CUSTOM_NVIM_PATH}" 110
sudo update-alternatives --install /usr/bin/vimdiff vimdiff "${CUSTOM_NVIM_PATH}" 110

ln -s $HOME/.apparatus/vim/vimrcs/vimrc.base $HOME/.vimrc
ln -s $HOME/.apparatus/vim $HOME/.vim
ln -s $HOME/.apparatus/git/gitconfig $HOME/.gitconfig
rm -rf $HOME/.config/kitty
ln -s $HOME/.apparatus/kitty/ $HOME/.config/
rm -rf $HOME/.config/nvim
ln -s $HOME/.apparatus/nvim/ $HOME/.config/
