#!/bin/bash

if ! [[ -d "$1" ]]
then
  echo "Expecting a directory as input"
  exit -1
fi

TEMP=$(mktemp -d /tmp/cbrmerge.XXXXXX)
mkdir -p $TEMP
echo unzipping in $TEMP
7z x -o$TEMP "$FULLPATH"

find "$1" -type f -name '*.cbz' -exec 7z x -o$TEMP {} \;

exit

# FULLPATH=$(realpath "$1")
# DIR=$(dirname -- "$FULLPATH")
# FILENAME=$(basename "$1")
# FILETYPE=$(file "$FULLPATH")
# WITHOUT_EXTENSION="${FILENAME%.*}"
#
# TEMP=$(mktemp -d /tmp/cbr2cbz.XXXXXX)
# mkdir -p $TEMP
# echo unzipping in $TEMP
# 7z x -o$TEMP "$FULLPATH"
# 7z -tzip a "$2"/"$WITHOUT_EXTENSION".cbz $TEMP
# rm -rf $TEMP
