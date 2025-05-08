# BITWARDEN
if ! command -v npm &> /dev/null
then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
    nvm install 14
fi

if ! command -v bw &> /dev/null
then
    npm install -g @bitwarden/cli
fi

# bw login $BW_EMAIL --passwordenv BW_PASSWORD
# bw unlock
#
