#!/bin/bash

if ! [[ -d "$1" ]]
then
  echo "Expecting a directory as input"
  exit -1
fi

TEMP=$(mktemp -d /tmp/cbzmerge.XXXXXX)
mkdir -p $TEMP
echo unzipping in $TEMP

find "${1}" -type f -name '*.cbz' -print | sort -h | cat -n | while read n d; do
  FULLPATH=$(realpath "$d")
  DIR=$(dirname -- "$FULLPATH")
  FILENAME=$(basename "$d")
  FILETYPE=$(file "$FULLPATH")
  WITHOUT_EXTENSION="${FILENAME%.*}"
  OUTPUT_DIR="$TEMP/$(printf "%02d" $n)"
  7z x -o"$OUTPUT_DIR" "$FULLPATH"

  find $OUTPUT_DIR -type f -print | sort -h | cat -n | while read n f; do
    full=$(basename -- "$f")
    ext="${full##*.}"
    output_path=$OUTPUT_DIR/$(printf "%04d" $n)."${ext}"
    mv -n "${f}" "${output_path}";
  done

  find $OUTPUT_DIR/* -type d -delete
done

find $TEMP -type f -print | sort -h | cat -n | while read n f; do
  full=$(basename -- "$f")
  ext="${full##*.}"
  output_path=$TEMP/$(printf "%04d" $n)."${ext}"
  mv -n "${f}" "${output_path}";
done

find $TEMP/* -type d -delete
7z -tzip a "$1".cbz $TEMP
rm -rf $TEMP
