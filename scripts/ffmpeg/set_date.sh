#!/bin/bash
set -e

filename=$(basename -- "$1")
extension="${filename##*.}"
filename="${filename%.*}"

echo Setting date to $filename.$extension

file_digits=${#filename}

if [ "$file_digits" -eq "8" ]; then
  created_at=$(date -j -f "%Y%m%d %H:%M:%S" "${filename} 00:00:00" +"%m/%d/%Y %H:%M:%S")
  output_filename=$(date -j -f "%Y%m%d %H:%M:%S" "${filename} 00:00:00" +"%Y%m%d")
  SetFile -d "$created_at" "$1"
  exit
fi

input_date=$2
date_digits=${#input_date}

if [ "$date_digits" -eq "4" ]; then
  created_at=$(date -j -f "%Y%m%d %H:%M:%S" "${input_date}0101 00:00:00" +"%m/%d/%Y %H:%M:%S")
  output_filename=$(date -j -f "%Y%m%d %H:%M:%S" "${input_date}0101 00:00:00" +"%Y")
elif [ "$date_digits" -eq "6" ]; then
  created_at=$(date -j -f "%Y%m%d %H:%M:%S" "${input_date}01 00:00:00" +"%m/%d/%Y %H:%M:%S")
  output_filename=$(date -j -f "%Y%m%d %H:%M:%S" "${input_date}01 00:00:00" +"%Y%m")
elif [ "$date_digits" -eq "8" ]; then
  created_at=$(date -j -f "%Y%m%d %H:%M:%S" "${input_date} 00:00:00" +"%m/%d/%Y %H:%M:%S")
  output_filename=$(date -j -f "%Y%m%d %H:%M:%S" "${input_date} 00:00:00" +"%Y%m%d")
else
  echo Bad date
  exit -1
fi

echo $created_at
echo $output_filename

SetFile -d "$created_at" "$1"
mv -vn "${1}" "${output_filename}.${extension}"
