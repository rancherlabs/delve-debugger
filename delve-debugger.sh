#!/bin/sh
set -e

NAMESPACE=$1
POD=$2
CONTAINER=$3
EXECUTABLE=$4

kubectl --namespace $1 debug pod/$2 --image=ghcr.io/moio/delve-debugger:latest --target=$3 --env="[EXECUTABLE=$4]"
kubectl --namespace $1 port-forward pod/$2 4000:4000
