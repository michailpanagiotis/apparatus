#!/bin/bash
# exit when any command fails
set -e

if [ -z ${EMAIL_ACCOUNT+x} ]
then
  if [ -z ${REFRESH_TOKEN+x} ]
  then
    >&2 echo neither REFRESH_TOKEN nor EMAIL_ACCOUNT was found in env
    exit -1
  fi
fi

if [ -z ${OAUTH2_PROVIDER+x} ]
then
  >&2 echo OAUTH2_PROVIDER not found in env
  exit -1
else
  if [[ "$OAUTH2_PROVIDER" == "google" ]]
  then
    OAUTH2_ENDPOINT="https://accounts.google.com/"
    OAUTH2_SCOPES="--scopes \"https://mail.google.com/\""
  else
    OAUTH2_ENDPOINT="https://login.microsoftonline.com/common/v2.0/"
    OAUTH2_SCOPES="--scopes \"https://outlook.office.com/IMAP.AccessAsUser.All\" --scopes offline_access"
  fi
fi

if [ -z ${OAUTH2_CLIENT_ID+x} ]
then
  >&2 echo OAUTH2_CLIENT_ID not found in env
  exit -1
fi

if [ -z ${OAUTH2_CLIENT_SECRET+x} ]
then
  >&2 echo OAUTH2_CLIENT_SECRET not found in env
  exit -1
fi

if [ -z ${REFRESH_TOKEN+x} ] || [ "${REFRESH_TOKEN}" == "null" ]
then
  >&2 echo Getting new access and refresh token
  RESPONSE=$(oauth2c \
    --auth-method client_secret_post \
    --no-prompt \
    --no-browser \
    --grant-type authorization_code \
    --response-types code \
    --response-mode query \
    --login-hint $EMAIL_ACCOUNT \
    --client-id $OAUTH2_CLIENT_ID \
    --client-secret $OAUTH2_CLIENT_SECRET \
    $OAUTH2_SCOPES \
    $OAUTH2_ENDPOINT)
else
  >&2 echo Getting new access token based on refresh_token
  RESPONSE=$(oauth2c \
    -s \
    --auth-method client_secret_post \
    --grant-type refresh_token \
    --refresh-token $REFRESH_TOKEN \
    --client-id $OAUTH2_CLIENT_ID \
    --client-secret $OAUTH2_CLIENT_SECRET \
    $OAUTH2_ENDPOINT)
fi

echo $RESPONSE | jq
