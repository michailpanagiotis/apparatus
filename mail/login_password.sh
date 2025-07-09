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

TIMESTAMP=$(date +%s)

if test -f ~/Maildir/config/$1.conf; then
  EXPIRES_AT=$(gpg -q --for-your-eyes-only --no-tty -d ~/Maildir/config/$1.conf | jq -r '.expires_at')

  if (( EXPIRES_AT > TIMESTAMP )); then
    echo Already logged in
    exit 0
  fi
fi

BW_STATUS=$(bw --nointeraction status | jq -r '.status')

if [[ "$BW_STATUS" == "locked" ]]
then
  BW_SESSION=$(bw unlock --raw)
  echo To keep the Bitwarden session run:
  echo export BW_SESSION=$BW_SESSION
  bw --session $BW_SESSION sync
fi

if [ -z ${BW_SESSION+x} ]
then
  echo Please start a bitwarden session with 'bw unlock' and set BW_SESSION
  exit -1
fi

BW_ITEM="$1 Webmail"
BW_ITEM=$(bw --session $BW_SESSION list items --search $BW_ITEM | jq -r ". | map(select(.name==\"$BW_ITEM\"))[0]")
BW_ID=$(echo $BW_ITEM | jq -r '.id')

if [ "${BW_ID}" == "null" ]
then
  echo Email $1 not in bitwarden
  exit -1
fi

echo Found bw id $BW_ID

echo $BW_ITEM

EMAIL_ACCOUNT=$(echo $BW_ITEM | jq -r '.login.username')
PASSWORD=$(echo $BW_ITEM | jq -r '.login.password')

if [ -z ${EMAIL_ACCOUNT+x} ]
then
  echo EMAIL_ACCOUNT not found in config
  exit -1
fi

if [ -z ${PASSWORD+x} ]
then
  echo PASSWORD not found in config
  exit -1
fi


EXPIRES_IN=3600

EXPIRES_AT=$((TIMESTAMP + EXPIRES_IN))

echo Storing gpg encrypted details for $EMAIL_ACCOUNT at ~/Maildir/config/...
jq -n \
  --arg EMAIL_ACCOUNT "$EMAIL_ACCOUNT" \
  --arg ACCESS_TOKEN "$PASSWORD" \
  --arg EXPIRES_AT "$EXPIRES_AT" \
'{ token: $ACCESS_TOKEN, account: $EMAIL_ACCOUNT, expires_at: $EXPIRES_AT }' | gpg --encrypt --armor --recipient Panos > ~/Maildir/config/$1.conf
