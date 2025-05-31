#!/usr/bin/env bash

function get_exif_timestamp () {
    createTimestamp=$(exiftool -d "%s" -T -CreationDate "$1")
    if ! [[ "$createTimestamp" == "-" ]]
    then
        echo $createTimestamp
    fi
}

function get_path_timestamp() {
    filename=$(basename -- "$1")
    extension="${filename##*.}"
    filename="${filename%.*}"

    datetime=$(echo $filename | sed -n 's/^\([0-9]\+\).*/\1/p')
    year="${datetime:0:4}"
    if ! [ -z "$year" ]
    then
        month="${datetime:4:2}"
        if [ -z "$month" ]; then month="01"; fi

        day="${datetime:6:2}"
        if [ -z "$day" ]; then day="01"; fi

	pathTimestamp=$(date -d "$year$month$day" +%s)
        echo $pathTimestamp
    fi
}

function get_timestamp() {
    exifTimestamp=$(get_exif_timestamp "$1")
    pathTimestamp=$(get_path_timestamp "$1")

    if [[ -z "$exifTimestamp" || -z "$pathTimestamp" ]]
    then
        if ! [ -z "$exifTimestamp" ]
        then
            echo $exifTimestamp
        elif ! [ -z "$pathTimestamp" ]
        then
            echo $pathTimestamp
        fi
    else
        exifDate=$(date -d @$exifTimestamp +%Y:%m:%d)
        pathDate=$(date -d @$pathTimestamp +%Y:%m:%d)

        if [[ "$exifDate" == "$pathDate" ]]
        then
            echo $exifTimestamp
        else
            if [[ $exifTimestamp -le $pathTimestamp ]]
            then
                echo $exifTimestamp
            else
                echo $pathTimestamp
            fi
        fi
    fi
}

function remodup {
    filename=$(basename -- "$1")
    extension="${filename##*.}"
    filename="${filename%.*}"

    datetime=$(echo $filename | sed -n 's/^\([0-9]\+\).*/\1/p')
    year="${datetime:0:4}"

    timestamp=$(get_timestamp "$1")

    if ! [ -z "$timestamp" ]
    then
        month="${datetime:4:2}"
        if [ -z "$month" ]; then month="01"; fi

        day="${datetime:6:2}"
        if [ -z "$day" ]; then day="01"; fi

	new_datetime=$(date -d @$timestamp +"%Y:%m:%d %T")
	new_access_datetime=$(date -d @$timestamp +"%Y%m%d%H%M.%S")

	exiftool "-AllDates=$new_datetime" "$1"
	touch -a -m -t $new_access_datetime "$1"

        echo $new_datetime $new_access_datetime $create_datetime "$1"
    fi
}

export -f get_exif_timestamp
export -f get_path_timestamp
export -f get_timestamp
export -f remodup

find /mnt/intenso/shared/Photos/orkomosia -type f -exec bash -c 'remodup "$1"' - {} \;
# find /mnt/intenso/shared/Media -type f -name '*20240609_panos2.mp4' -exec bash -c 'remodup "$1"' - {} \;
