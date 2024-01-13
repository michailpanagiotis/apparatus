export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$PATH:$HOME/.apparatus/scripts:$GOROOT/bin:$GOPATH/bin

standup () {
    GIT_PRETTY_DATE="%cd"
    GIT_PRETTY_FORMAT="%Cred%h%Creset %Cgreen@ $GIT_PRETTY_DATE%Creset %s %C(bold blue)%d%Creset"
    LAST_WEEK=$(date -d 'last week' -I"date")

    git --no-pager log --since=\"${LAST_WEEK}\" --author="$(git config user.name)" --abbrev-commit --oneline --pretty="format:${GIT_PRETTY_FORMAT}" --all --date=short
}

alias rgf='rg --hidden --ignore-vcs --vimgrep --files ~/ | rg'
alias ggrep='rg . | fzf | cut -d ":" -f 1'
alias vgrep='vim $(rg . | fzf | cut -d ":" -f 1)'
export FZF_DEFAULT_COMMAND='rg --hidden --ignore-vcs --vimgrep --files ~/'
export FZF_CTRL_T_COMMAND="rg --hidden --ignore-vcs --vimgrep --null --files ~/ | xargs -0 dirname | uniq"

source $HOME/.apparatus/scripts/profile/jira
source $HOME/.apparatus/scripts/profile/git
source $HOME/.apparatus/scripts/profile/hub
source $HOME/.apparatus/scripts/profile/docker
