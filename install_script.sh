#!/bin/bash

INSTALL_BASE=1
if [[ -z "${PASSWORD}" ]]; then
  echo Provide root password as PASSWORD env variable
  exit
fi

if [[ -z "${BW_EMAIL}" ]]; then
  echo Provide BitWarden email as BW_EMAIL env variable
  exit
fi
if [[ -z "${BW_PASSWORD}" ]]; then
  echo Provide BitWarden password as BW_PASSWORD env variable
  exit
fi

if [ "${INSTALL_BASE}" -eq "1" ]; then
  echo === Installing base...
  echo $PASSWORD | sudo -S apt-get update
  echo $PASSWORD | sudo -S apt-get --assume-yes install curl fzf git ripgrep ncdu build-essential
  echo === Installing base...done!
fi

ssh -T git@github.com
status=$?

if [ "${status}" -eq "255" ]; then
    echo === Connecting to github...

    if [ ! -f "$HOME/.ssh/id_rsa" ]
    then
        ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa -C "michailpanagiotis@gmail.com" <<<y >/dev/null 2>&1
    fi
    echo Github public key:
    cat $HOME/.ssh/id_rsa.pub
    echo Copy the above public key to github, then press any key...
    read answer

    ssh -T git@github.com
    status=$?

    if [ "${status}" -eq "255" ]; then
        echo === Connecting to github...failed!
        exit -1
    fi
    echo === Connecting to github...done!
fi

if [ ! -d "$HOME/.apparatus" ]
then
    git clone https://github.com/michailpanagiotis/apparatus $HOME/.apparatus
    if [ ! -f "$HOME/.zshrc" ]
    then
        ln -s $HOME/.apparatus/.zshrc $HOME/.zshrc
    fi

    if [ ! -f "$HOME/.gitconfig" ]
    then
        ln -s $HOME/.apparatus/git/gitconfig $HOME/.gitconfig
    fi

    if [ ! -d "$HOME/.config/nvim" ]
    then
        ln -s $HOME/.apparatus/nvim $HOME/.config/nvim
    fi
fi

# NEOVIM
if ! command -v nvim &> /dev/null
then
    wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.deb
    echo $PASSWORD | sudo -S apt install ./nvim-linux64.deb
    rm ./nvim-linux64.deb
    # SET NVIM AS DEFAULT
    echo $PASSWORD | sudo -S update-alternatives --install /usr/bin/ex ex $(which nvim) 110
    echo $PASSWORD | sudo -S update-alternatives --install /usr/bin/vi vi $(which nvim) 110
    echo $PASSWORD | sudo -S update-alternatives --install /usr/bin/view view $(which nvim) 110
    echo $PASSWORD | sudo -S update-alternatives --install /usr/bin/vim vim $(which nvim) 110
    echo $PASSWORD | sudo -S update-alternatives --install /usr/bin/vimdiff vimdiff $(which nvim) 110
    echo $PASSWORD | sudo -S update-alternatives --set ex $(which nvim)
    echo $PASSWORD | sudo -S update-alternatives --set vi $(which nvim)
    echo $PASSWORD | sudo -S update-alternatives --set view $(which nvim)
    echo $PASSWORD | sudo -S update-alternatives --set vim $(which nvim)
    echo $PASSWORD | sudo -S update-alternatives --set vimdiff $(which nvim)
fi

# ZSH
if ! command -v zsh &> /dev/null
then
    echo $PASSWORD | sudo -S apt-get --assume-yes install zsh
    if [ ! -d "$HOME/.oh-my-zsh" ]
    then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        PRE_ZSHRC=$HOME/.zshrc.pre-oh-my-zsh
        if test -f "$PRE_ZSHRC"; then
            rm $PRE_ZSHRC
        fi
    fi
fi

# BITWARDEN
if ! command -v npm &> /dev/null
then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
    nvm install 14
fi

if ! command -v bw &> /dev/null
then
    npm install -g @bitwarden/cli
fi

# bw login $BW_EMAIL --passwordenv BW_PASSWORD
# bw unlock
#

# https://stackoverflow.com/a/226722
inquire ()  {
  echo  -n "$1 [y/N]? "
  read answer
  finish="-1"
  while [ "$finish" = '-1' ]
  do
    finish="1"
    if [ "$answer" = '' ];
    then
      answer="n"
    else
      case $answer in
        y | Y | yes | YES ) answer="y";;
        n | N | no | NO ) answer="n";;
        *) finish="-1";
           echo -n 'Invalid response -- please reenter:';
           read answer;;
       esac
    fi
  done
}

inquire "Install now?"
echo $answer
