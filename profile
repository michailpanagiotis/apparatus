#!/usr/bin/env bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH="${HOME}/.pyenv/shims:${PATH}"


export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$PATH:$HOME/.apparatus/scripts:$GOROOT/bin:$GOPATH/bin

alias rgf='rg --hidden --ignore-vcs --vimgrep --files ~/ | rg'
alias ggrep='rg . | fzf | cut -d ":" -f 1'
alias vgrep='vim $(rg . | fzf | cut -d ":" -f 1)'
export FZF_DEFAULT_COMMAND='rg --hidden --ignore-vcs --vimgrep --files ~/'
export FZF_CTRL_T_COMMAND="rg --hidden --ignore-vcs --vimgrep --null --files ~/ | xargs -0 dirname | uniq"

standup () {
    GIT_PRETTY_DATE="%cd"
    GIT_PRETTY_FORMAT="%Cred%h%Creset %Cgreen@ $GIT_PRETTY_DATE%Creset %s %C(bold blue)%d%Creset"
    LAST_WEEK=$(date -d 'last week' -I"date")

    git --no-pager log --since=\"${LAST_WEEK}\" --author="$(git config user.name)" --abbrev-commit --oneline --pretty="format:${GIT_PRETTY_FORMAT}" --all --date=short
}

alias vim="nvim"
alias vi="nvim"

export INVOICE_VAT_PERCENT=24
export INVOICE_RATE_AMOUNT=50
export INVOICE_CURRENCY=EUR

source $HOME/.apparatus/scripts/profile/jira
source $HOME/.apparatus/scripts/profile/git
source $HOME/.apparatus/scripts/profile/hub
source $HOME/.apparatus/scripts/profile/docker
source $HOME/.apparatus/scripts/profile/timew
source $HOME/.apparatus/scripts/profile/projects/*

alias oauth2=~/.apparatus/scripts/oauth2/get_access_token.sh

# SSH Agent should be running, once
# if ! ps -ef | grep "[s]sh-agent" &>/dev/null; then
    echo Starting SSH Agent
    eval $(ssh-agent -s)
    ssh-add -t 1d /home/wert/.ssh/id_github
# fi

# export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
# if ! ssh-add -l &>/dev/null; then
#      echo Adding keys...
#      ssh-add -t 1d /home/wert/.ssh/id_github
# fi

keyring () {
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_github
}
