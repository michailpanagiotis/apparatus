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

BW_STATUS=$(bw --nointeraction status | jq -r '.status')

if [[ "$BW_STATUS" == "locked" ]]
then
  BW_SESSION=$(bw unlock --raw)
  echo To keep the Bitwarden session run:
  echo export BW_SESSION=$BW_SESSION
fi

if [ -z ${BW_SESSION+x} ]
then
  echo Please start a bitwarden session with 'bw unlock' and set BW_SESSION
  exit -1
fi

bw --session $BW_SESSION sync
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

echo Storing gpg encrypted details for $EMAIL_ACCOUNT at ~/Maildir/config/...
echo $EMAIL_ACCOUNT | gpg --encrypt --armor --recipient Panos > ~/Maildir/config/$1.account
echo $PASSWORD | gpg --encrypt --armor --recipient Panos > ~/Maildir/config/$1.access
