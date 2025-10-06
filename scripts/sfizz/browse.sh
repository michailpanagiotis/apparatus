#!/usr/bin/env bash

function check_input {
  if [[ -z "${SFIZZ_NAME}" ]]; then
    echo Variable SFIZZ_NAME is required
    exit 1
  fi

  if [[ -z "${SFIZZ_IN}" ]]; then
    echo Variable SFIZZ_IN is required
    exit 1
  fi

  if [[ -z "${SFIZZ_OUT_LEFT}" ]]; then
    echo Variable SFIZZ_OUT_LEFT is required
    exit 1
  fi

  if [[ -z "${SFIZZ_OUT_RIGHT}" ]]; then
    echo Variable SFIZZ_OUT_RIGHT is required
    exit 1
  fi

  if [[ -z "${SFIZZ_SOUNDS_PATH}" ]]; then
    echo Variable SFIZZ_SOUNDS_PATH is required
    exit 1
  fi
}

BROWSER_SCREEN="${SFIZZ_NAME}-browser"

function load_instrument {
  screen -S "${SFIZZ_NAME}" -p 0 -X stuff "load_instrument \"$(realpath "$1")\"^M"
}

function midi_monitor {
  aseqdump -p 16:1 | \
  while IFS=" ," read src ev1 ev2 ch label1 data1 label2 data2 rest; do
      case "$ev1 $ev2 $data1" in
          "Note on 99" ) screen -S "${BROWSER_SCREEN}" -p 0 -X stuff "j^M" ;;
          "Note on 98" ) screen -S "${BROWSER_SCREEN}" -p 0 -X stuff "k^M" ;;
      esac
  done
}

function browser {
  function shutdown {
    screen -XS "$SFIZZ_NAME" quit
  }

  trap 'shutdown' EXIT

  midi_monitor &
  # cd ~/.sounds/sfz && find ./ -type f -name '*.sfz' | fpp -s -ko -ai -c load_instrument
  find "${SFIZZ_SOUNDS_PATH}" -type f -name '*.dspreset' -o -name '*.sfz' | ~/bin/fpp -s -ko -ai -c load_instrument
}

export -f load_instrument
export -f browser
export -f midi_monitor

check_input

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
screen -dmS "$SFIZZ_NAME" "$SCRIPT_DIR"/start.sh

screen -dmS "${BROWSER_SCREEN}" bash -c "browser"
sleep 1
screen -S "${BROWSER_SCREEN}" -p 0 -X stuff "^M"

# screen -r browser
