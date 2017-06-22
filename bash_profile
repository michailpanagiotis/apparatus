[[ -s "$HOME/.profile" ]] && source "$HOME/.profile" # Load the default .profile
[[ -s "$HOME/.bash_aliases" ]] && source "$HOME/.bash_aliases" # Load the .bash_aliases

# PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w$(__git_ps1 "[\[\033[0;
function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

export PS1="\[$(tput setaf 3)\]\u\[$(tput setaf 4)\]@\[$(tput setaf 1)\]\h\[$(tput setaf 7)\]:\[$(tput setaf 4)\]\W \[$(tput setaf 2)\]\$(parse_git_branch)\[$(tput setaf 4)\]\\$\[$(tput sgr0)\] "
# export PS1='\[\e]0;\w\a\]\n\[\e[32m\]\u@\h:\[\e[33m\]\w\[\e[0m\]\n\e[31m\]$(parse_git_branch)\e[0m\]λ '

if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi

eval "$(hub alias -s)"
eval "$(rbenv init -)"

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

export GOPATH=~/Projects/
export PATH="/usr/local/sbin:$PATH"
eval $(/usr/libexec/path_helper -s)
