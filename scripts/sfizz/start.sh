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

function connect_jack {
  sleep 2
  jack_connect "$ALSA_MIDI_IN_1" "$SFIZZ_NAME":input
  jack_connect "$SFIZZ_NAME":output_1 "$SFIZZ_OUT_LEFT"
  jack_connect "$SFIZZ_NAME":output_2 "$SFIZZ_OUT_RIGHT"
}

check_input
connect_jack &
sfizz_jack --client_name "$SFIZZ_NAME"
