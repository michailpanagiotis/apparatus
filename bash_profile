[[ -s "$HOME/.profile" ]] && source "$HOME/.profile" # Load the default .profile
[[ -s "$HOME/.bash_aliases" ]] && source "$HOME/.bash_aliases" # Load the .bash_aliases
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w$(__git_ps1 "[\[\033[0;
function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

export PS1="\[$(tput setaf 3)\]\u\[$(tput setaf 4)\]@\[$(tput setaf 1)\]\h\[$(tput setaf 7)\]:\[$(tput setaf 4)\]\W \[$(tput setaf 2)\]\$(parse_git_branch)\[$(tput setaf 4)\]\\$\[$(tput sgr0)\] "
# export PS1='\[\e]0;\w\a\]\n\[\e[32m\]\u@\h:\[\e[33m\]\w\[\e[0m\]\n\e[31m\]$(parse_git_branch)\e[0m\]λ '

if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

export GOPATH=~/Projects/
export PATH="/usr/local/sbin:$PATH"
eval $(/usr/libexec/path_helper -s)

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# eval "$(hub alias -s)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

[[ -s "/Users/mike/.gvm/scripts/gvm" ]] && source "/Users/mike/.gvm/scripts/gvm"
