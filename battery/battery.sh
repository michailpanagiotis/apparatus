#!/bin/bash

RED="\033[0;31m"
YELLOW="\033[0;33m"
GREEN="\033[0;32m"
if [ "$1" == "--tmux" ]; then
    GREEN="#[fg=green]"
    YELLOW="#[fg=yellow]"
    RED="#[fg=red]"
fi

batt=`pmset -g batt`
running_on=`echo $batt | awk -F ''\''' '{print $2}'`
perc=`echo $batt | grep -o "[0-9]*\%"`
p=`echo $perc | cut -d% -f1`

if [ "$p" -ge "50" ]; then
    color=$GREEN
elif [ "$p" -ge "20" ]; then
    color=$YELLOW
elif [ "$p" -lt "20" ]; then
    color=$RED
fi

if [ "$running_on" == "Battery Power" ]; then
    battery="=[ $perc ]="
else
    battery="~( $perc )~"
fi

echo -e $color$battery
