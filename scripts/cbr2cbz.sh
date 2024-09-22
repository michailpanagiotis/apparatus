#!/bin/bash

if ! [[ -f "$1" ]]
then
  echo "Expecting a file as input"
  exit -1
fi

FULLPATH=$(realpath "$1")
DIR=$(dirname -- "$FULLPATH")
FILENAME=$(basename "$1")
FILETYPE=$(file "$FULLPATH")
WITHOUT_EXTENSION="${FILENAME%.*}"

TEMP=$(mktemp -d /tmp/cbr2cbz.XXXXXX)
mkdir -p $TEMP
echo unzipping in $TEMP
7z x -o$TEMP "$FULLPATH"
7z -tzip a "$2"/"$WITHOUT_EXTENSION".cbz $TEMP
rm -rf $TEMP
