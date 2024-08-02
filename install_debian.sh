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
source <(curl -s https://raw.githubusercontent.com/michailpanagiotis/apparatus/master/scripts/install/install_wireguard.sh)
install_git
install_apparatus
install_nvim
