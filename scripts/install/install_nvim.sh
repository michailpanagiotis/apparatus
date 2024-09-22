#!/usr/bin/env bash
set -e
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod +x nvim.appimage
./nvim.appimage --appimage-extract
mv squashfs-root /
ln -s /squashfs-root/AppRun /usr/bin/nvim
mkdir -p ~/.vim/files/info
rm nvim.appimage
update-alternatives --install /usr/bin/ex ex /usr/bin/nvim 110
update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 110
update-alternatives --install /usr/bin/view view /usr/bin/nvim 110
update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 110
update-alternatives --install /usr/bin/vimdiff vimdiff /usr/bin/nvim 110
nvim

# sudo apt remove neovim
# sudo apt install ninja-build gettext cmake unzip curl
# git clone https://github.com/neovim/neovim
# cd neovim
# make CMAKE_BUILD_TYPE=RelWithDebInfo
# ls
# cd build
# cpack -G DEB
# # sudo dpkg -i nvim-linux64.deb
# # sudo apt remove neovim
# sudo dpkg -i --force-overwrite  nvim-linux64.deb
# nvim
