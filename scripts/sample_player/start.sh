#!/usr/bin/env bash
function load_instrument {
  screen -S sfizz -p 0 -X stuff "load_instrument \"$(realpath "$1")\"^M"
}

function midi_monitor {
  aseqdump -p 16:1 | \
  while IFS=" ," read src ev1 ev2 ch label1 data1 label2 data2 rest; do
      case "$ev1 $ev2 $data1" in
          "Note on 99" ) screen -S browser -p 0 -X stuff "j^M" ;;
          "Note on 98" ) screen -S browser -p 0 -X stuff "k^M" ;;
      esac
  done
}

function browser {
  function shutdown {
    jack_disconnect "a2j:Keystation 49 MK3 [16] (capture): [0] Keystation 49 MK3(USB MIDI)" sfizz:input
    # jack_disconnect "a2j:XStation [16] (capture): [0] XStation" sfizz:input
    screen -XS sfizz quit
  }

  trap 'shutdown' EXIT

  midi_monitor &
  # cd ~/.sounds/sfz && find ./ -type f -name '*.sfz' | fpp -s -ko -ai -c load_instrument
  find ~/.sounds/ -type f -name '*.dspreset' -o -name '*.sfz' | fpp -s -ko -ai -c load_instrument
}

export -f load_instrument
export -f browser
export -f midi_monitor

function setup {
  screen -dmS sfizz sfizz_jack --jack_autoconnect
  sleep 1
  jack_connect "a2j:Keystation 49 MK3 [16] (capture): [0] Keystation 49 MK3(USB MIDI)" sfizz:input
  # jack_connect "a2j:XStation [16] (capture): [0] XStation" sfizz:input
}

setup
screen -dmS browser bash -c "browser"

screen -S browser -p 0 -X stuff "^M"
screen -r browser
