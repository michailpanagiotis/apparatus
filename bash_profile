[[ -s "$HOME/.profile" ]] && source "$HOME/.profile" # Load the default .profile

# PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w$(__git_ps1 "[\[\033[0;
function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

export PS1="\[$(tput setaf 3)\]\u\[$(tput setaf 4)\]@\[$(tput setaf 1)\]\h\[$(tput setaf 7)\]:\[$(tput setaf 4)\]\W \[$(tput setaf 2)\]\$(parse_git_branch)\[$(tput setaf 4)\]\\$\[$(tput sgr0)\] "
