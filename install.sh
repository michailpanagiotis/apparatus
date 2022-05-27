echo 'Please, manually install brave, kitty, kinto and bitwarden cli (bw)'

sudo apt-get install jq

flatpak install --noninteractive bitwarden
flatpak install --noninteractive slack
flatpak install --noninteractive zoom
flatpak install --noninteractive spotify

cd $HOME/.apparatus/

if test -f "JetBrainsMono-2.242.zip"; then
    echo "JetBrains Mono exists"
else
    curl -Ls -o jetbrains_mono.zip https://download-cdn.jetbrains.com/fonts/JetBrainsMono-2.242.zip?_gl=1*uv3l58*_ga*MjAzODU5MDk1LjE2NTM1NzczMTg.*_ga_9J976DJZ68*MTY1MzU3NzMxNi4xLjEuMTY1MzU3NzMyOC4w&_ga=2.27630709.816184028.1653577318-203859095.1653577318
fi
unzip -o jetbrains_mono.zip -d ~/.local/share/fonts
fc-cache -f -v


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

echo 'Setting config for ssh'
rm -rf $HOME/.ssh/config
ln -s $HOME/.apparatus/ssh/config $HOME/.ssh/config
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
echo 'Setting config for kinto'
rm -rf $HOME/.config/kinto/kinto.py
ln -s $HOME/.apparatus/kinto/kinto.py $HOME/.config/kinto/kinto.py
sudo systemctl restart xkeysnail

# SSH
bw list items --search id_rsa | jq -r '.[0].fields[0].value' > $HOME/.ssh/id_rsa
chmod 0600 $HOME/.ssh/id_rsa
mkdir $HOME/.ssh/controlmasters

# Pop OS
gsettings set org.gnome.shell.extensions.pop-shell activate-launcher "['<Super>space']"
