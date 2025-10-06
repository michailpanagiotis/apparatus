#!/usr/bin/env bash
if [[ -z "${SFIZZ_NAME}" ]]; then
  echo Variable SFIZZ_NAME is required
  exit 1
fi

if [[ -z "${MIDI_MONITOR_PORT}" ]]; then
  echo Variable MIDI_MONITOR_PORT is required. Run 'aseqdump -l' to select
  exit 1
fi

BROWSER_SCREEN="${SFIZZ_NAME}-browser"

aseqdump -p $MIDI_MONITOR_PORT | \
while IFS=" ," read src ev1 ev2 ch label1 data1 label2 data2 rest; do
    case "$ev1 $ev2 $data1" in
        "Note on 99" ) screen -S "${BROWSER_SCREEN}" -p 0 -X stuff "j^M" ;;
        "Note on 98" ) screen -S "${BROWSER_SCREEN}" -p 0 -X stuff "k^M" ;;
    esac
done
