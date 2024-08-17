#!/bin/bash
set -e

filename=$(basename -- "$1")
extension="${filename##*.}"
filename="${filename%.*}"

output=$(echo "${filename}_encoded.mp4")

command=$(echo ffmpeg -i \""$1"\" -c:v copy -c:a copy -movflags faststart -tag:v hvc1 \"$output\")

if eval $command; then
  if [[ "$filename" =~ ^[0-9]{8}$ ]]; then
    rm "$1"
    ~/.apparatus/scripts/ffmpeg/set_date.sh "$output" $filename
  else
    mv ${output} "$1"
  fi
fi
