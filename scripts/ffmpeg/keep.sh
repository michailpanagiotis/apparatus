#!/bin/bash
set -e

filename=$(basename -- "$1")
extension="${filename##*.}"
filename="${filename%.*}"

commands=()
files=()
from="00:00:00"
for n in $(seq 2 $#); do
  date=${!n}
  arrIN=(${date//-/ })

  from=${arrIN[0]}
  to=${arrIN[1]}

  part=$(($n-1))
  output=$(echo "${filename}_part${part}.${extension}")
  command=$(echo ffmpeg -i \""$1"\" -ss $from -to $to -c:v libx265 -c:a copy -preset ultrafast -x265-params crf=30 -movflags faststart -maxrate 2M -bufsize 2M -tag:v hvc1 \"$output\" ";")

  # echo $command
  commands+=( $command )
  files+=( $output )
  # from=$(date -r $next "+%H:%M:%S")
done

for ((i = 0; i < ${#files[@]}; i++))
do
  echo "file \"${files[$i]}\""
done > list.txt

output=$(echo "${filename}_cut.${extension}")
# cat list.txt
command=$(echo ffmpeg -safe 0 -f concat -i list.txt -c copy \"$output\")

# echo $command
commands+=( $command )
full_command=$(echo ${commands[@]})

echo $full_command

# eval $full_command
#
# rm list.txt
# for file in ${files[@]}; do
#   rm "$file"
# done
