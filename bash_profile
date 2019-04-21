[[ -s "$HOME/.profile" ]] && source "$HOME/.profile"
[[ -s "$HOME/.bash_aliases" ]] && source "$HOME/.bash_aliases"

export PATH="/usr/local/sbin:$PATH"

# Locale
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# fzf
[ -f "$HOME/.fzf.bash" ] && source "$HOME/.fzf.bash"
export FZF_DEFAULT_COMMAND='rg --files --no-ignore-vcs --hidden'

# PS1
function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

export PS1="\[$(tput setaf 3)\]\u\[$(tput setaf 4)\]@\[$(tput setaf 1)\]\h\[$(tput setaf 7)\]:\[$(tput setaf 4)\]\W \[$(tput setaf 2)\]\$(parse_git_branch)\[$(tput setaf 4)\]\\$\[$(tput sgr0)\] "

# Bash completion
export BASH_COMPLETION_COMPAT_DIR="/usr/local/etc/bash_completion.d"
[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"

# Go
export GOPATH="$HOME/Projects/go"
eval $(/usr/libexec/path_helper -s)
[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"

# rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

