#!/usr/bin/env bash
set -e

read -p "Enter email: " EMAIL

wget -O $HOME/.gitconfig -q https://raw.githubusercontent.com/michailpanagiotis/apparatus/master/git/gitconfig
if ! test -f ~/.ssh/id_github.pub; then
  ssh-keygen -t ed25519 -C "michailpanagiotis@gmail.com" -f $HOME/.ssh/id_github
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/id_github
fi
echo Add the following public key to github:
cat ~/.ssh/id_github.pub
ssh -T git@github.com
