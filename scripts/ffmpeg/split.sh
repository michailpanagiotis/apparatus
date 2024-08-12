#!/bin/bash
set -e

commands=()
from="00:00:00"
for n in $(seq 2 $#); do
  # echo INDEX $n
  date=${!n}
  # echo DATE $date
  curr=$(date -j -f "%H:%M:%S" "$date" +%s)
  # echo $curr
  next=$(echo "$curr + 1" | bc)
  prev=$(echo "$curr - 1" | bc)

  to=$(date -r $prev "+%H:%M:%S")

  output=$(echo "cut_${from}_${to}.mp4")

  command=$(echo ffmpeg -i \""$1"\" -ss $from -to $to -c:v libx265 -c:a copy -preset ultrafast -x265-params crf=30 \"$output\" ";")

  # echo $command
  commands+=( $command )
  from=$(date -r $next "+%H:%M:%S")
done

output=$(echo "cut_${from}.mp4")
command=$(echo ffmpeg -i \""$1"\" -ss $from -c:v libx265 -c:a copy -preset ultrafast -x265-params crf=30 \"$output\")
# echo $command
commands+=( $command )

full_command=$(echo ${commands[@]})

eval $full_command
