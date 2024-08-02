#!/usr/bin/env bash
set -e
if [ ! -d "$HOME/.apparatus" ]
then
  git clone https://github.com/michailpanagiotis/apparatus $HOME/.apparatus
else
  echo "Apparatus exists"
fi

if [ ! -f "$HOME/.zshrc" ]
then
  ln -s $HOME/.apparatus/.zshrc $HOME/.zshrc
else
  echo "Zsh config exists"
fi

if [ ! -d "$HOME/.config/nvim" ]
then
  mkdir -p $HOME/.config
  ln -s $HOME/.apparatus/nvim $HOME/.config/nvim
else
  echo "Nvim config exists"
fi
