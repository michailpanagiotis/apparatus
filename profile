docker_exec () {
    docker exec -it -e COLUMNS=$COLUMNS -e LINES=$LINES "$1" $2
}

docker_logs () {
    docker logs "$1" --follow
}

docker_remove_containers () {
    docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)
}

docker_remove_volumes () {
    docker volume prune
}

pull_request () {
    current=$(git branch --show-current)
    message=$(git show-branch --no-name HEAD)
    echo Creating PR for branch $current with message \'"${message}"\'
    hub pull-request -b master -h "$current" -m "$message [master]"
    hub pull-request -b next -h "$current" -m "$message [next]"
    hub pull-request -b staging2 -h "$current" -m "$message [staging2]"
}

reflog-json () {
  git \
    --no-pager reflog \
    --abbrev=40 \
    --no-abbrev-commit \
    --author="$(git config user.name)" \
    --pretty="format:%Cred%h%Creset %Cgreen@ %cI%Creset %C(bold blue)%gd%Creset %s" \
    --since="2023-10-06 07:09:55+00:00" \
    --exclude="HEAD" \
    --branches="*" \
    --format="%h${TAB}%an${TAB}%cI${TAB}%s${TAB}%gd" | tr "\"" "\`" \
    | awk -F '\t' '{printf "{\"commit\":\"%s\",\"author\":\"%s\",\"date\":\"%s\",\"message\":\"%s\",\"revision\":\"%s\"}\n", $1, $2 ,$3, $4, $5}' \
    | jq --slurp 'map(.)'
}

sync-staging() {
  current=$(git branch --show-current)
  git stash --include-untracked
  git checkout master
  git pull
  git checkout next
  git pull
  git merge --no-edit master
  git push
  git checkout staging2
  git pull
  git merge --no-edit master
  git push
  git checkout ${current}
  git stash pop
}

standup () {
    GIT_PRETTY_DATE="%cd"
    GIT_PRETTY_FORMAT="%Cred%h%Creset %Cgreen@ $GIT_PRETTY_DATE%Creset %s %C(bold blue)%d%Creset"
    LAST_WEEK=$(date -d 'last week' -I"date")

    git --no-pager log --since=\"${LAST_WEEK}\" --author="$(git config user.name)" --abbrev-commit --oneline --pretty="format:${GIT_PRETTY_FORMAT}" --all --date=short
}

alias dex=docker_exec
alias dlg=docker_logs
alias drc=docker_remove_containers
alias drv=docker_remove_volumes
alias pr=pull_request

alias rgf='rg --hidden --ignore-vcs --vimgrep --files ~/ | rg'
alias ggrep='rg . | fzf | cut -d ":" -f 1'
alias vgrep='vim $(rg . | fzf | cut -d ":" -f 1)'
export FZF_DEFAULT_COMMAND='rg --hidden --ignore-vcs --vimgrep --files ~/'
export FZF_CTRL_T_COMMAND="rg --hidden --ignore-vcs --vimgrep --null --files ~/ | xargs -0 dirname | uniq"
