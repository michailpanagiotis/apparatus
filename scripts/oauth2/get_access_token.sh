#!/bin/bash
# exit when any command fails
set -e

usage () {
    cat <<HELP_USAGE
Usage:
  $0 <email_account>
HELP_USAGE
}

if ! [ "$#" -eq 1 ]
then
    usage
    exit 1
fi


mkdir -p $HOME/.config/oauth2c

# Read config file of schema:
# {
#   "EMAIL_ACCOUNT": ,
#   "GPG_ID": ,
#   "OAUTH2_PROVIDER": ,
#   "OAUTH2_CLIENT_ID": ,
#   "OAUTH2_CLIENT_SECRET": ,
#   "OAUTH2_REDIRECT_PORT":
# }
CONFIG_FILE=$HOME/.config/oauth2c/${1}.json

if ! [ -f ${CONFIG_FILE} ]
then
  echo Unknown config file $CONFIG_FILE
  exit -1
fi

eval "$( jq -r 'to_entries | map_values(@sh "export \(.key)=\(.value)")[]' $CONFIG_FILE )"

if [ -z ${EMAIL_ACCOUNT+x} ]
then
  echo EMAIL_ACCOUNT not found in config
  exit -1
fi

if [ -z ${OAUTH2_PROVIDER+x} ]
then
  echo OAUTH2_PROVIDER not found in config
  exit -1
fi

if [ -z ${OAUTH2_CLIENT_ID+x} ]
then
  echo OAUTH2_CLIENT_ID not found in config
  exit -1
fi


if [ -z ${OAUTH2_CLIENT_SECRET+x} ]
then
  echo OAUTH2_CLIENT_SECRET not found in config
  exit -1
fi

if [ -z ${OAUTH2_REDIRECT_PORT+x} ]
then
  echo OAUTH2_REDIRECT_PORT not found in config
  exit -1
else
  OAUTH2_REDIRECT_URL="http://localhost:${OAUTH2_REDIRECT_PORT}"
fi

if [ -z ${GPG_ID+x} ]
then
  echo GPG_ID not found in config
  exit -1
fi

output=$HOME/.config/oauth2c/$EMAIL_ACCOUNT.gpg


read -p "Have you ssh-ed on this machine using 'ssh -L ${PORT}:localhost:${PORT} <this-machine>? (y/N) " -n 1 -r
echo    # (optional) move to a new line
if ! [[ $REPLY =~ ^[Yy]$ ]]
then
  exit
fi

if [[ "$OAUTH2_PROVIDER" == "google" ]]
then
  OAUTH2_ENDPOINT="https://accounts.google.com/"
  OAUTH2_SCOPES="--scopes \"https://mail.google.com/\""
else
  OAUTH2_ENDPOINT="https://login.microsoftonline.com/common/v2.0/"
  OAUTH2_SCOPES="--scopes \"https://outlook.office.com/IMAP.AccessAsUser.All\" --scopes offline_access"
fi

oauth2c \
  --no-prompt \
  --no-browser \
  --grant-type authorization_code \
  --response-types code \
  --response-mode query \
  --auth-method client_secret_post \
  --redirect-url $OAUTH2_REDIRECT_URL \
  --client-id $OAUTH2_CLIENT_ID \
  --client-secret $OAUTH2_CLIENT_SECRET \
  --login-hint $EMAIL_ACCOUNT \
  $OAUTH2_SCOPES \
  $OAUTH2_ENDPOINT | jq -r '.access_token' | gpg --encrypt --armor --recipient $GPG_ID > $output

echo Wrote to ${output}:
gpg2 -q --for-your-eyes-only --no-tty -d $output
