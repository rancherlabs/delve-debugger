#!/bin/sh
set -e

source ./versions
NAMESPACE=$1
POD=$2
CONTAINER=$3
EXECUTABLE=$4
LOCAL_PORT="${5:-4000}"

kubectl --namespace $1 port-forward pod/$2 $LOCAL_PORT:4000 &
PORT_FORWARDING_PID=$!
echo `tput bold`
echo 'Please wait for the line "debug layer=debugger continuing" to appear...'
echo `tput sgr0`
kubectl --namespace $1 debug -it pod/$2 --image=ghcr.io/moio/delve-debugger:$DLV_VERSION-$DELVE_DEBUGGER_VERSION --target=$3 --env="[EXECUTABLE=$4]"
kill ${PORT_FORWARDING_PID}
