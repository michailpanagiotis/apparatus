#!/bin/bash
set -e

filename=$(basename -- "$1")
original=$(echo "$(cd "$(dirname "$1")"; pwd)/$(basename "$1")")
output=$(echo "$(cd "$(dirname "$1")"; pwd)/$(basename "$1")".compressed.mp4)
exif_original=$(echo "$(cd "$(dirname "$1")"; pwd)/$(basename "$1")".compressed.mp4_original)
backup=$(echo "$(cd "$(dirname "$1")"; pwd)/$(basename "$1")".bak.mp4)
extension="${filename##*.}"
filename="${filename%.*}"

echo "$original -> $backup -> $output"

mv -n "$original" "$backup"
ffmpeg -i "$backup" -c:v libx265 -c:a copy -preset ultrafast -x265-params crf=23 -movflags faststart -maxrate 2M -bufsize 2M -tag:v hvc1 "$output"

if [ $? -eq 0 ]; then
  echo ffmeg converted!
else
  exit -1
fi

exiftool -TagsFromFile "$backup" "-all:all>all:all" "$output"

if [ $? -eq 0 ]; then
  echo exif set!
else
  exit -1
fi

mv -n "$output" "$original"

if [ $? -eq 0 ]; then
  echo original overwritten!
else
  exit -1
fi

rm "$backup"
rm "$exif_original"
