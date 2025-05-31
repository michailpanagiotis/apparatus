#!/bin/bash
if [[ -z "${RESTIC_PASSWORD}" ]]; then
  echo "RESTIC_PASSWORD is not set"
  exit -1
fi

echo Connecting to repo...

restic -r sftp:grey:/mnt/external/restic/nextcloud_shared --verbose snapshots

echo Backing up..

cd /media/storage/Shared; restic -r sftp:grey:/mnt/external/restic/nextcloud_shared --verbose backup --tag nextcloud ./

echo Duplicating backup...

ssh grey -t 'bash -l -c "rsync -avz --progress /mnt/external/restic/ netcup:restic"'
