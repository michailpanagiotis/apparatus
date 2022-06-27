#!/bin/bash
# exit when any command fails
set -e

echo "Installing for Debian."

apt-get install curl git unzip
install nodejs npm -y
npm install -g @bitwarden/cli
bw login
bw list items --search id_rsa | jq -r '.[0].notes' > $HOME/.ssh/id_rsa
chmod 0600 ~/.ssh/id_rsa
eval "$(ssh-agent -s)"
ssh -T git@github.com
git clone git@github.com:michailpanagiotis/apparatus.git .apparatus

curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage
mv nvim.appimage /usr/bin/nvim

sudo update-alternatives --install /usr/bin/ex ex /usr/bin/nvim 110
sudo update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 110
sudo update-alternatives --install /usr/bin/view view /usr/bin/nvim 110
sudo update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 110
sudo update-alternatives --install /usr/bin/vimdiff vimdiff /usr/bin/nvim 110

curl -Ls -o jetbrains_mono.zip "https://download-cdn.jetbrains.com/fonts/JetBrainsMono-2.242.zip?_gl=1*uv3l58*_ga*MjAzODU5MDk1LjE2NTM1NzczMTg.*_ga_9J976DJZ68*MTY1MzU3NzMxNi4xLjEuMTY1MzU3NzMyOC4w&_ga=2.27630709.816184028.1653577318-203859095.1653577318"
unzip -o jetbrains_mono.zip -d ~/.local/share/fonts
fc-cache -f -v
rm jetbrains_mono.zip

# VIM and PlugInstall
