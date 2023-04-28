apt-get install -y curl g++
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
./nvim.appimage --appimage-extract
./squashfs-root/AppRun --version
mv squashfs-root /
ln -s /squashfs-root/AppRun /usr/bin/nvim
nvim
