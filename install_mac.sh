#!/bin/bash
# exit when any command fails
set -e

echo "Installing for Mac."

if ! command -v brew &> /dev/null
then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew install bitwarden-cli fzf gawk git-standup htop bottom imagemagick isync jq mysql-client ncdu neomutt neovim saulpw/vd/visidata up wget
