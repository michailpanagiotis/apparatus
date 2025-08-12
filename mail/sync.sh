#!/bin/bash
# exit when any command fails
set -e

if [ -z ${SASL_PATH+x} ]
then
  echo SASL_PATH not found. Install cyrus-sasl and it XOAuth2 plugin
  exit -1
fi

if ! [ "$#" -eq 1 ]
then
  declare -a arr=("gmail" "td" "hotmail" "ceid" "duvve")
  ~/.apparatus/mail/login_all.sh
  for i in "${arr[@]}"
  do
     echo Syncing $i...
     mbsync -c ~/.apparatus/mail/mbsyncrc $i
  done
else
  echo Syncing $1...
  ~/.apparatus/mail/login.sh $1 > ~/out 2>error
  mbsync -c ~/.apparatus/mail/mbsyncrc $1
fi

notmuch new
