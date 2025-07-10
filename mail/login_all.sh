#!/bin/bash
# exit when any command fails
set -e

BW_STATUS=$(bw --nointeraction status | jq -r '.status')

if [[ "$BW_STATUS" == "locked" ]]
then
  BW_PASSWORD=$(gpg -q --for-your-eyes-only --no-tty -d ~/Maildir/config/bw)
  BW_SESSION=$(bw unlock --raw "$BW_PASSWORD")
  echo To keep the Bitwarden session run:
  echo export BW_SESSION=$BW_SESSION
  bw --session $BW_SESSION sync
fi

if [ -z ${BW_SESSION+x} ]
then
  echo Please start a bitwarden session with 'bw unlock' and set BW_SESSION
  exit -1
fi

BW_SESSION=$BW_SESSION ~/.apparatus/mail/login.sh gmail
BW_SESSION=$BW_SESSION ~/.apparatus/mail/login.sh td
BW_SESSION=$BW_SESSION ~/.apparatus/mail/login.sh hotmail
BW_SESSION=$BW_SESSION ~/.apparatus/mail/login.sh ceid
BW_SESSION=$BW_SESSION ~/.apparatus/mail/login.sh duvve
