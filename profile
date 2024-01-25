#!/usr/bin/env bash

export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$PATH:$HOME/.apparatus/scripts:$GOROOT/bin:$GOPATH/bin

standup () {
    GIT_PRETTY_DATE="%cd"
    GIT_PRETTY_FORMAT="%Cred%h%Creset %Cgreen@ $GIT_PRETTY_DATE%Creset %s %C(bold blue)%d%Creset"
    LAST_WEEK=$(date -d 'last week' -I"date")

    git --no-pager log --since=\"${LAST_WEEK}\" --author="$(git config user.name)" --abbrev-commit --oneline --pretty="format:${GIT_PRETTY_FORMAT}" --all --date=short
}

invoice() {
  if [ -z $1 ]; then
    echo "Usage:\n\tinvoice [invoice data in json]"
    return 1
  fi
  tera --template $HOME/.apparatus/jinja/invoice.template.html $1
}

__get_invoice_json_from_timewarrior() {
  timew billing | jq -L$HOME/.apparatus/scripts/jq \
   --arg INVOICE_RATE_AMOUNT "$INVOICE_RATE_AMOUNT" \
   --arg INVOICE_CURRENCY "$INVOICE_CURRENCY" \
   --arg INVOICE_VAT_PERCENT "$INVOICE_VAT_PERCENT" \
   -rf $HOME/.apparatus/scripts/jq/timew_to_invoice.jq
}

__get_full_invoice_data() {
  tera -e --env-key env --template ~/.apparatus/jinja/invoice_data.template.json --stdin < <(
    __get_invoice_json_from_timewarrior
  )
}

invoice_from_timewarrior() {
  tera --template $HOME/.apparatus/jinja/invoice.template.html --stdin < <(__get_full_invoice_data)
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
source $HOME/.apparatus/scripts/profile/timew
