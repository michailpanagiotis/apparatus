#!/bin/bash
set -e

filename=$(basename -- "$1")
extension="${filename##*.}"
filename="${filename%.*}"

original=$(echo "$(cd "$(dirname "$1")"; pwd)/$(basename "$1")")
dir=$(dirname "$original")
backup=$(echo "$(cd "$(dirname "$1")"; pwd)/$(basename "$1")".bak.pdf)

mv -n "$original" "$backup"

gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/screen -dNOPAUSE -dQUIET -dBATCH -sOutputFile="$original" "$backup"

if [ $? -eq 0 ]; then
  echo pdf converted!
else
  exit -1
fi

rm "$backup"
