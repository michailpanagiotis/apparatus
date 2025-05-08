apt-get install -y curl g++
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
./nvim.appimage --appimage-extract
./squashfs-root/AppRun --version
sudo mv squashfs-root /
sudo ln -s /squashfs-root/AppRun /usr/bin/nvim
nvim
