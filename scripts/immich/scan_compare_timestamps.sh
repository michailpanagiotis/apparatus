#!/usr/bin/env bash

set -e

function die() {
    echo "$1": "$2"
    exit -1
}

function get_exif_timestamp () {
    createTimestamp=$(exiftool -d "%s" -T -CreateDate "$1")
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

function compare_timestamps() {
    exifTimestamp=$(get_exif_timestamp "$1")
    pathTimestamp=$(get_path_timestamp "$1")
    modifiedTimestamp=$(date -r "$1" +%s)

    if [[ -z "$exifTimestamp" ]]
    then
        die "$1" "NO EXIF"
    fi

    if [[ -z "$pathTimestamp" ]]
    then
        die "$1" "NO PATH"
    fi

    if [[ -z "$modifiedTimestamp" ]]
    then
        die "$1" "NO MODIFIED"
    fi

    exifDate=$(date -d @$exifTimestamp +%Y:%m:%d)
    pathDate=$(date -d @$pathTimestamp +%Y:%m:%d)
    modDate=$(date -d @$modifiedTimestamp +%Y:%m:%d)

    if ! [[ "$exifDate" == "$pathDate" ]]
    then
        die "$1" "Exif not same as path"
    fi

    if ! [[ "$exifDate" == "$modDate" ]]
    then
        die "$1" "Exif not same as mod"
    fi
}

function remodup {
    compare_timestamps "$1"
}

export -f get_exif_timestamp
export -f get_path_timestamp
export -f compare_timestamps
export -f remodup
export -f die

find /mnt/intenso/shared/Photos -type f \( -exec bash -c 'remodup "$1"' - {} \; \)
