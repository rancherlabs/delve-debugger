#!/bin/sh
set -e

CONTAINER=$1
EXECUTABLE=k3s
LOCAL_PORT="${1:-4000}"

$(dirname $0)/../delve-debugger-docker.sh ${CONTAINER} ${EXECUTABLE} ${LOCAL_PORT}
