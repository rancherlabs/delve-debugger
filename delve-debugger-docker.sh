#!/bin/bash
set -e

CONTAINER=$1
EXECUTABLE=$2
LOCAL_PORT="${5:-4000}"
VERSION="${VERSION:-latest}"

# --privileged note: this is needed in order to debug --privileged containers
# in other cases, --cap-add=SYS_ADMIN --cap-add=SYS_PTRACE may suffice instead

docker run --name delve-debugger --privileged --pid=container:$CONTAINER --env EXECUTABLE=$EXECUTABLE --publish 127.0.0.1:$LOCAL_PORT:4000/tcp --rm ghcr.io/rancherlabs/delve-debugger:$VERSION
