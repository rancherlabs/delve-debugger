#!/usr/bin/env bash
set -e

PID=`pgrep $EXECUTABLE`

exec /root/go/bin/dlv attach $PID --continue --accept-multiclient --api-version 2 --headless --log --listen :4000
