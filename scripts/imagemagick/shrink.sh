#!/bin/bash
set -e

filename=$(basename -- "$1")
extension="${filename##*.}"
filename="${filename%.*}"

original=$(echo "$(cd "$(dirname "$1")"; pwd)/$(basename "$1")")
dir=$(dirname "$original")
output=$(echo "$dir"/"$filename".jpg)
exif_original=$(echo "$output"_original)
backup=$(echo "$(cd "$(dirname "$1")"; pwd)/$(basename "$1")".bak.mp4)

echo "$original -> $backup -> $output"

mv -n "$original" "$backup"

magick "$backup" -strip -interlace Plane -quality 92 -quiet "$output"

if [ $? -eq 0 ]; then
  echo image converted!
else
  exit -1
fi

exiftool -TagsFromFile "$backup" "-all:all>all:all" "$output"

if [ $? -eq 0 ]; then
  echo exif set!
else
  exit -1
fi

rm "$backup"
rm "$exif_original"
