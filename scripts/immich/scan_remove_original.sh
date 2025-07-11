#!/usr/bin/env bash

function remodup {
    filename=$(basename -- "$1")
    extension="${filename##*.}"
    filename="${filename%.*}"

    dir="$(cd "$(dirname -- "$1")" >/dev/null; pwd -P)"

    copied="$dir/${filename}.${extension}_original"

    # echo $1 $copied

    if [ -f "$copied" ]; then
      echo "Remove $copied"
      rm "$copied"
    fi

    # datetime=$(echo $filename | sed -n 's/^\([0-9]\+\).*/\1/p')
    # year="${datetime:0:4}"
    #
    # timestamp=$(get_timestamp "$1")
    #
    # if ! [ -z "$timestamp" ]
    # then
    #     month="${datetime:4:2}"
    #     if [ -z "$month" ]; then month="01"; fi
    #
    #     day="${datetime:6:2}"
    #     if [ -z "$day" ]; then day="01"; fi
    #
	# new_datetime=$(date -d @$timestamp +"%Y:%m:%d %T")
	# new_access_datetime=$(date -d @$timestamp +"%Y%m%d%H%M.%S")
    #
	# exiftool "-AllDates=$new_datetime" "$1"
	# touch -a -m -t $new_access_datetime "$1"
    #
    #     echo $new_datetime $new_access_datetime $create_datetime "$1"
    # fi
}

export -f remodup

find /mnt/intenso/shared/Media -type f -exec bash -c 'remodup "$1"' - {} \;
