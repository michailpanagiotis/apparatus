#!/usr/bin/env bash
set -e

install_base() {
  echo Installing packages...
  apt-get update
  apt-get install wget git curl zsh jq wireguard fzf build-essential kitty-terminfo ncdu htop
  sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
}

install_toolkit() {
  if ! test -f /tmp/bundle.bash; then
    wget -O /tmp/bundle.bash -q https://github.com/timo-reymann/bash-tui-toolkit/releases/download/1.5.1/bundle.bash
  fi
  source /tmp/bundle.bash
}

install_base
install_toolkit
PEER_NUMBER=$(with_validate 'input "Please enter the peer number"' validate_present)
source <(curl -s https://raw.githubusercontent.com/michailpanagiotis/apparatus/master/scripts/install/install_wireguard.sh)
source <(curl -s https://raw.githubusercontent.com/michailpanagiotis/apparatus/master/scripts/install/install_github.sh)
source <(curl -s https://raw.githubusercontent.com/michailpanagiotis/apparatus/master/scripts/install/install_apparatus.sh)
source <(curl -s https://raw.githubusercontent.com/michailpanagiotis/apparatus/master/scripts/install/install_nvim.sh)

sed 's/#SystemMaxUse=/SystemMaxUse=100M/g' -i /etc/systemd/journald.conf && systemctl restart systemd-journald.service
