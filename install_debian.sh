#!/usr/bin/env bash
set -e

install_base() {
  echo Installing packages...
  apt-get update
  apt-get install wget git curl zsh jq wireguard fzf build-essential
  sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
}

install_toolkit() {
  if ! test -f /tmp/bundle.bash; then
    wget -O /tmp/bundle.bash -q https://github.com/timo-reymann/bash-tui-toolkit/releases/download/1.5.1/bundle.bash
  fi
  source /tmp/bundle.bash
}

install_wireguard() {
  if ! test -f /etc/wireguard/private.key; then
    wg genkey | tee /etc/wireguard/private.key
    chmod go= /etc/wireguard/private.key
    show_success "Created wireguard private key"
  else
    show_success "Wireguard private key exists"
  fi

  if ! test -f /etc/wireguard/public.key; then
    cat /etc/wireguard/private.key | wg pubkey | tee /etc/wireguard/public.key
    show_success "Created wireguard public key"
    PUBLIC_KEY=$(cat /etc/wireguard/public.key)
    echo "Add the following to your Wireguard server configuration:"
    echo "  [Peer]"
    echo "  PublicKey=${PUBLIC_KEY}"
    echo "  AllowedIPs = fda7:bcf9:b71c::${PEER_NUMBER}/128"
  else
    show_success "Wireguard public key exists"
  fi


  if ! test -f /etc/wireguard/wg0.conf; then
    WIREGUARD_ENDPOINT=$(with_validate 'input "Please enter your Wireguard server endpoint"' validate_present)
    PRIVATE_KEY=$(cat /etc/wireguard/private.key)
    cat > /etc/wireguard/wg0.conf <<- EOM
[Interface]
Address = fda7:bcf9:b71c::${PEER_NUMBER}/64
ListenPort = 51820
PrivateKey = ${PRIVATE_KEY}

[Peer]
PublicKey = EMoxRoV0nQldMzAFjcFa7Rkuk2fMO+83YX3R7ppOMXQ=
AllowedIPs = fda7:bcf9:b71c::/64
Endpoint = ${WIREGUARD_ENDPOINT}:51820
PersistentKeepalive = 25
EOM
    show_success "Created wireguard configuration"
  else
    show_success "Wireguard configuration exists"
  fi

  IS_UP=$(wg show)

  if [ -z "$IS_UP" ]; then
    wg-quick up wg0
    show_success 'Wireguard is up'
  else
    show_success 'Wireguard is up'
  fi
}

install_git() {
  wget -O $HOME/.gitconfig -q https://raw.githubusercontent.com/michailpanagiotis/apparatus/master/git/gitconfig
  if ! test -f ~/.ssh/id_ed25519.pub; then
    ssh-keygen -t ed25519 -C "michailpanagiotis@gmail.com"
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519
    echo Add the following public key to github:
    cat ~/.ssh/id_ed25519.pub
  fi
  ssh -T git@github.com
}

install_apparatus() {
  if [ ! -d "$HOME/.apparatus" ]
  then
    git clone https://github.com/michailpanagiotis/apparatus $HOME/.apparatus
  else
    show_success "Apparatus exists"
  fi

  if [ ! -f "$HOME/.zshrc" ]
  then
    ln -s $HOME/.apparatus/.zshrc $HOME/.zshrc
  else
    show_success "Zsh config exists"
  fi

  if [ ! -d "$HOME/.config/nvim" ]
  then
    mkdir -p $HOME/.config
    ln -s $HOME/.apparatus/nvim $HOME/.config/nvim
  else
    show_success "Nvim config exists"
  fi
}

install_nvim() {
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
}

install_base
install_toolkit
PEER_NUMBER=$(with_validate 'input "Please enter the peer number"' validate_present)
install_wireguard
install_git
install_apparatus
install_nvim
