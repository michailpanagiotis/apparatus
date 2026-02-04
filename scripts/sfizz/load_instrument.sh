#!/usr/bin/env bash
function check_input {
  if [[ -z "$1" ]]; then
    echo Command expects one argument
    exit 1
  fi
}

echo "load_instrument \"$(realpath "$1")\"" > $XDG_RUNTIME_DIR/sfizz.stdin
