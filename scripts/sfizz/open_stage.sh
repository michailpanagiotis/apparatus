#!/usr/bin/env bash
if [[ -z "${OPEN_STAGE_SERVER_EXECUTABLE}" ]]; then
  echo Variable OPEN_STAGE_SERVER_EXECUTABLE is required
  exit 1
fi

if [[ -z "${OPEN_STAGE_LISTENER_PORT}" ]]; then
  echo Variable OPEN_STAGE_LISTENER_PORT is required
  exit 1
fi

if [[ -z "${OPEN_STAGE_SESSION}" ]]; then
  echo Variable OPEN_STAGE_SESSION is required
  exit 1
fi

node $OPEN_STAGE_SERVER_EXECUTABLE --send 127.0.0.1:${OPEN_STAGE_LISTENER_PORT} --load "${OPEN_STAGE_SESSION}"
