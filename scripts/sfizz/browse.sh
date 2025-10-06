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
}

BROWSER_SCREEN="${SFIZZ_NAME}-browser"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
readarray -t PRESETS < <($SCRIPT_DIR/list_presets.sh)
BROWSER_COMMAND="browser ${PRESETS[@]@Q}"

function load_instrument {
  screen -S "${SFIZZ_NAME}" -p 0 -X stuff "load_instrument \"$(realpath "$1")\"^M"
}

function browser {
  presets=( "$@" )
  function shutdown {
    screen -XS "$SFIZZ_NAME" quit
  }
  trap 'shutdown' EXIT
  printf '%s\n' "${presets[@]}"  | ~/bin/fpp -s -ko -ai -c load_instrument
}

export -f load_instrument
export -f browser

check_input

screen -dmS "$SFIZZ_NAME" "$SCRIPT_DIR"/start.sh
screen -dmS "${BROWSER_SCREEN}" bash -c "$BROWSER_COMMAND"
sleep 1
screen -S "${BROWSER_SCREEN}" -p 0 -X stuff "^M"

screen -r "${BROWSER_SCREEN}"
