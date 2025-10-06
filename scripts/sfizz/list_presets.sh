#!/usr/bin/env bash
if [[ -z "${SFIZZ_SOUNDS_PATH}" ]]; then
  echo Variable SFIZZ_SOUNDS_PATH is required
  exit 1
fi

find "${SFIZZ_SOUNDS_PATH}" -type f -not -path '*mappings*' \( -name '*.dspreset' -o -name '*.sfz' \) | sort
