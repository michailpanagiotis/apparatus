pacman -Sy kitty-terminfo wireguard-tools zsh nginx unzip

systemctl enable wg-quick@wg0.service
systemctl enable nginx
systemctl daemon-reload

sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon
echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf

nix profile install nixpkgs#git
nix profile install nixpkgs#neovim
nix profile install nixpkgs#ripgrep
nix profile install nixpkgs#fzf
nix profile install nixpkgs#wget
nix profile install nixpkgs#rsync
nix profile install nixpkgs#restic
nix profile install nixpkgs#tmux
nix profile install nixpkgs#unzip

chsh -s /root/.nix-profile/bin/zsh

# https://wiki.archlinux.org/title/Power_management/Suspend_and_hibernate#Disable_sleep_completely
nvim /etc/systemd/sleep.conf

create /mnt/external
add UUID=FFBA-ED4A /mnt/external exfat rw,user,umask=0000,nofail 0 0 to /etc/fstab
add consoleblank=60 to /boot/loader/entries/arch.conf


SETUP WIREGUARD
