[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export PS1="%10F%n%f:%11F%1~%f \$ "
export PATH="/usr/local/opt/mysql-client/bin:$PATH"

export PATH="/usr/local/sbin:$PATH"
export GPG_TTY=$(tty)

export EDITOR="/usr/local/bin/nvim"

source ~/.apparatus/profile
