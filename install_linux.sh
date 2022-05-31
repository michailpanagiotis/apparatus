#!/bin/bash
# exit when any command fails
set -e

echo "Installing for Linux."

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

# SSH
bw list items --search id_rsa | jq -r '.[0].fields[0].value' > $HOME/.ssh/id_rsa
chmod 0600 $HOME/.ssh/id_rsa
mkdir $HOME/.ssh/controlmasters


echo 'Setting config for ssh'
rm -rf $HOME/.ssh/config
ln -s $HOME/.apparatus/ssh/config $HOME/.ssh/config
echo 'Setting config for kinto'
rm -rf $HOME/.config/kinto/kinto.py
ln -s $HOME/.apparatus/kinto/kinto.py $HOME/.config/kinto/kinto.py
sudo systemctl restart xkeysnail

# Pop OS
gsettings set org.gnome.shell.extensions.pop-shell activate-launcher "['<Super>space']"
