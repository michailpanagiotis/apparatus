#!/bin/bash
set -e

commands=()
from="00:00:00"
for n in $(seq 2 $#); do
  # echo INDEX $n
  date=${!n}
  # echo DATE $date

  if [ "$(uname)" == "Darwin" ]; then
      # Do something under Mac OS X platform
      curr=$(date -j -f "%H:%M:%S" "$date" +%s)
  elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
      # Do something under GNU/Linux platform
      curr=$(date --date="$date" "+%s")
  fi

  # echo $curr
  next=$(echo "$curr + 1" | bc)
  prev=$(echo "$curr - 1" | bc)

  if [ "$(uname)" == "Darwin" ]; then
      to=$(date -r $prev "+%H:%M:%S")
  elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
      to=$(date -d "@$prev" "+%H:%M:%S")
  fi

  output=$(echo "cut_${from}_${to}.mp4")

  command=$(echo ffmpeg -i \""$1"\" -ss $from -to $to -c:v libx265 -c:a copy -preset ultrafast -x265-params crf=30 -movflags faststart -maxrate 2M -bufsize 2M -tag:v hvc1 \"$output\" ";")

  # echo $command
  commands+=( $command )

  if [ "$(uname)" == "Darwin" ]; then
      from=$(date -r $next "+%H:%M:%S")
  elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
      from=$(date -d "@$next" "+%H:%M:%S")
  fi
done

output=$(echo "cut_${from}.mp4")
command=$(echo ffmpeg -i \""$1"\" -ss $from -c:v libx265 -c:a copy -preset ultrafast -x265-params crf=30 -movflags faststart -maxrate 2M -bufsize 2M -tag:v hvc1 \"$output\")
# echo $command
commands+=( $command )

full_command=$(echo ${commands[@]})

echo $full_command
eval $full_command
