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

BW_STATUS=$(bw --nointeraction status | jq -r '.status')

if [[ "$BW_STATUS" == "locked" ]]
then
  echo Please start a bitwarden session with 'bw unlock' and set BW_SESSION
  exit -1
fi

if [ -z ${BW_SESSION+x} ]
then
  echo Please start a bitwarden session with 'bw unlock' and set BW_SESSION
  exit -1
fi

BW_ITEM="$1 OAuth"
# bw unlock --session $BW_SESSION
BW_ITEM=$(bw --session $BW_SESSION list items --search $BW_ITEM | jq -r ". | map(select(.name==\"$BW_ITEM\"))[0]")

echo $BW_ITEM | jq -r '.fields[0].value | fromjson | .EMAIL_ACCOUNT'
