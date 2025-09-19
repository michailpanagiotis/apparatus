#!/usr/bin/env bash

set -e

for dir in $(find ~/Backups/ -depth -maxdepth 1 -mindepth 1 -type d); do
  echo Syncing "$dir"
  rsync -avzt --inplace --no-perms --no-owner --no-group --progress --delete "$dir" pi:/mnt/external/
done

curl https://kuma.duvve.gr/api/push/YmoXCIb6Y7\?status\=up\&msg\=OK\&ping\=
