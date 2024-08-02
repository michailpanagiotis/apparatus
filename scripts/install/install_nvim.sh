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
