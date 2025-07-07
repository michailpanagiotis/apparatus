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
BW_ITEM=$(bw list items --search $BW_ITEM | jq -r ". | map(select(.name==\"$BW_ITEM\"))[0]")
BW_ID=$(echo $BW_ITEM | jq -r '.id')

if [ "${BW_ID}" == "null" ]
then
  echo Email $1 not in bitwarden
  exit -1
fi

echo Found bw id $BW_ID
CUSTOM_FIELDS=$(echo $BW_ITEM | jq -rc '.fields[0] | select(.name=="oauth2c")')
OAUTH2C_FIELDS=$(echo $CUSTOM_FIELDS | jq -rc '.| .value')

# Add env variables
eval "$(echo $OAUTH2C_FIELDS | jq -rc 'to_entries | map_values("export \(.key)=\(.value)") | .[]')"

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


if [[ "$OAUTH2_PROVIDER" == "google" ]]
then
  OAUTH2_ENDPOINT="https://accounts.google.com/"
  OAUTH2_SCOPES="--scopes \"https://mail.google.com/\""
else
  OAUTH2_ENDPOINT="https://login.microsoftonline.com/common/v2.0/"
  OAUTH2_SCOPES="--scopes \"https://outlook.office.com/IMAP.AccessAsUser.All\" --scopes offline_access"
fi


if [ -z ${REFRESH_TOKEN+x} ]
then
  echo Getting new access and refresh token
  RESPONSE=$(oauth2c \
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
    $OAUTH2_ENDPOINT)

  ACCESS_TOKEN=$(echo $RESPONSE |jq -r '.access_token')
  REFRESH_TOKEN=$(echo $RESPONSE |jq -r '.refresh_token')

  NEW_OAUTH2C_FIELDS=$(echo $OAUTH2C_FIELDS | jq --arg REFRESH_TOKEN "$REFRESH_TOKEN" '.REFRESH_TOKEN=$REFRESH_TOKEN')
  NEW_CUSTOM_FIELDS=$(echo $NEW_OAUTH2C_FIELDS | jq -rc '{name: "oauth2c", value: . | tostring }' )
  NEW_BW_ITEM=$(echo $BW_ITEM | jq -c --arg ACCESS_TOKEN "$ACCESS_TOKEN" --argjson CUSTOM_FIELDS $NEW_CUSTOM_FIELDS '.notes=$ACCESS_TOKEN | .fields=[$CUSTOM_FIELDS]')

  echo Storing access and refresh token for $EMAIL_ACCOUNT...
  echo $NEW_BW_ITEM | bw encode | bw edit item $BW_ID
else
  echo Getting new access token based on refresh_token
  RESPONSE=$(oauth2c \
    --auth-method client_secret_post \
    --no-prompt \
    --no-browser \
    --grant-type refresh_token \
    --response-types code \
    --response-mode query \
    --redirect-url $OAUTH2_REDIRECT_URL \
    --client-id $OAUTH2_CLIENT_ID \
    --client-secret $OAUTH2_CLIENT_SECRET \
    --login-hint $EMAIL_ACCOUNT \
    --refresh-token $REFRESH_TOKEN \
    $OAUTH2_SCOPES \
    $OAUTH2_ENDPOINT)

  ACCESS_TOKEN=$(echo $RESPONSE |jq -r '.access_token')
  NEW_BW_ITEM=$(echo $BW_ITEM | jq -c --arg ACCESS_TOKEN "$ACCESS_TOKEN" '.notes=$ACCESS_TOKEN')

  echo Storing access token for $EMAIL_ACCOUNT...
  echo $NEW_BW_ITEM | bw encode | bw edit item $BW_ID
fi
