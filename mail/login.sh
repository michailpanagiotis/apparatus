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
  EMAIL_ACCOUNT=$(gpg -q --for-your-eyes-only --no-tty -d ~/Maildir/config/$1.conf | jq -r '.account')

  if (( EXPIRES_AT > TIMESTAMP )); then
    echo Already logged in $EMAIL_ACCOUNT
    exit 0
  fi
fi

>&2 echo checking status

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

BW_ITEM_NAME="mbsync $1"
BW_ITEM=$(bw --session $BW_SESSION list items --search $BW_ITEM_NAME | jq -r ". | map(select(.name==\"$BW_ITEM_NAME\"))[0]")
BW_ID=$(echo $BW_ITEM | jq -r '.id')

if [ "${BW_ID}" == "null" ]
then
  echo Item \'$BW_ITEM_NAME\' not in bitwarden
  exit -1
fi

BW_ID=$(echo $BW_ITEM | jq -r '.id')
echo Found bw id $BW_ID

BW_TYPE=$(echo $BW_ITEM | jq -r '.type')

if (( BW_TYPE == 1 ));
then
  echo Logging in with username/password
  EMAIL_ACCOUNT=$(echo $BW_ITEM | jq -r '.login.username')
  ACCESS_TOKEN=$(echo $BW_ITEM | jq -r '.login.password')
  if [ -z ${EMAIL_ACCOUNT+x} ]
  then
    echo EMAIL_ACCOUNT not found in config
    exit -1
  fi
  if [ -z ${ACCESS_TOKEN+x} ]
  then
    echo PASSWORD not found in config
    exit -1
  fi
  EXPIRES_IN=3600
else
  echo Logging in with OAuth2
  REFRESH_TOKEN=$(echo $BW_ITEM | jq -r '.notes')
  CUSTOM_FIELDS=$(echo $BW_ITEM | jq -rc '.fields[0] | select(.name=="oauth2c")')
  OAUTH2C_FIELDS=$(echo $CUSTOM_FIELDS | jq -rc '.| .value')

  >&2 echo $OAUTH2C_FIELDS

  # Add env variables
  eval "$(echo $OAUTH2C_FIELDS | jq -rc 'to_entries | map_values("export \(.key)=\(.value)") | .[]')"

  RESPONSE=$(REFRESH_TOKEN=$REFRESH_TOKEN ~/.apparatus/mail/oauth.sh)

  EXPIRES_IN=$(echo $RESPONSE |jq -r '.expires_in')
  ACCESS_TOKEN=$(echo $RESPONSE |jq -r '.access_token')

  if [ -z ${REFRESH_TOKEN+x} ] || [ "${REFRESH_TOKEN}" == "null" ]
  then
    REFRESH_TOKEN=$(echo $RESPONSE |jq -r '.refresh_token')
    NEW_BW_ITEM=$(echo $BW_ITEM | jq -c --arg REFRESH_TOKEN "$REFRESH_TOKEN" '.notes=$REFRESH_TOKEN')

    echo Storing refresh token for $EMAIL_ACCOUNT...
    echo $NEW_BW_ITEM | bw --session $BW_SESSION encode | bw --session $BW_SESSION edit item $BW_ID
  fi
fi

if [ -z ${EXPIRES_IN+x} ]
then
  echo EXPIRES_IN not found
  exit -1
fi

EXPIRES_AT=$((TIMESTAMP + EXPIRES_IN))

echo Storing gpg encrypted details for $EMAIL_ACCOUNT at ~/Maildir/config/...
jq -n \
  --arg EMAIL_ACCOUNT "$EMAIL_ACCOUNT" \
  --arg ACCESS_TOKEN "$ACCESS_TOKEN" \
  --arg EXPIRES_AT "$EXPIRES_AT" \
'{ token: $ACCESS_TOKEN, account: $EMAIL_ACCOUNT, expires_at: $EXPIRES_AT }' | gpg --encrypt --armor --recipient Panos > ~/Maildir/config/$1.conf
