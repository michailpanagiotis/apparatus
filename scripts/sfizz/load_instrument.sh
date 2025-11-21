#!/usr/bin/env bash
if [[ -z "$1" ]]; then
  echo Command expects at least one argument
  exit 1
fi

if [[ -z "$2" ]]; then
  echo Command expects two arguments
  exit 1
fi

echo "load_instrument \"$(realpath "$2")\"" > $XDG_RUNTIME_DIR/sfizz-$1.stdin
