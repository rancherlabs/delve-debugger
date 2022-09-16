#!/bin/sh
set -e

CONTAINER=$1
EXECUTABLE=k3s

$(dirname $0)/../delve-debugger-docker.sh ${CONTAINER} ${EXECUTABLE}
