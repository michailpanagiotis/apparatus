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

if [ -z ${BW_SESSION+x} ]
then
  echo Please start a bitwarden session with 'bw unlock' and set BW_SESSION
  exit -1
fi

bw sync

BW_ITEM="$1 OAuth"
BW_ID=$(bw list items --search $BW_ITEM | jq -r ". | map(select(.name==\"$BW_ITEM\"))[0] | .id")

if [ "${BW_ID}" == "null" ]
then
  echo Email $1 not in bitwarden
  exit -1
fi

echo Found bw id $BW_ID

eval "$(bw get --pretty item $BW_ID | jq -rc '.fields[0] | select(.name=="oauth2c").value | fromjson | to_entries | map_values("export \(.key)=\(.value)") | .[]')"

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

output=$HOME/.config/oauth2c/$EMAIL_ACCOUNT.gpg


if [[ "$OAUTH2_PROVIDER" == "google" ]]
then
  OAUTH2_ENDPOINT="https://accounts.google.com/"
  OAUTH2_SCOPES="--scopes \"https://mail.google.com/\""
else
  OAUTH2_ENDPOINT="https://login.microsoftonline.com/common/v2.0/"
  OAUTH2_SCOPES="--scopes \"https://outlook.office.com/IMAP.AccessAsUser.All\" --scopes offline_access"
fi

ACCESS_TOKEN=$(oauth2c \
  --auth-method client_secret_post \
  --no-prompt \
  --no-browser \
  --grant-type authorization_code \
  --response-types code \
  --response-mode query \
  --redirect-url $OAUTH2_REDIRECT_URL \
  --client-id $OAUTH2_CLIENT_ID \
  --client-secret $OAUTH2_CLIENT_SECRET \
  --login-hint $EMAIL_ACCOUNT \
  $OAUTH2_SCOPES \
  $OAUTH2_ENDPOINT | jq -r '.access_token')

echo Storing access token for $EMAIL_ACCOUNT...

bw get item $BW_ID | jq -c ".notes=\"${ACCESS_TOKEN}\"" | bw encode | bw --quiet edit item $BW_ID
