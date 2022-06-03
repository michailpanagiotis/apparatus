export PS1="\n\[\[\033[01;33m\][\W] \$\[\033[00m\]\[\033[0;00m\] "

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

alias dex=docker_exec
alias dlg=docker_logs
alias drc=docker_remove_containers
alias drv=docker_remove_volumes
