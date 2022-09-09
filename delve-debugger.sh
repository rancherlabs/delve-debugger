#!/bin/sh
set -e

NAMESPACE=$1
POD=$2
CONTAINER=$3
EXECUTABLE=$4

kubectl --namespace $1 port-forward pod/$2 4000 &
echo `tput bold`
echo 'Please wait for the line "debug layer=debugger continuing" to appear...'
echo `tput sgr0`
kubectl --namespace $1 debug -it pod/$2 --image=ghcr.io/moio/delve-debugger:1.9.1-1 --target=$3 --env="[EXECUTABLE=$4]"
