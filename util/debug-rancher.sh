#!/bin/sh
set -e

NAMESPACE=cattle-system
POD=$(kubectl --namespace ${NAMESPACE} get pod --selector='app=rancher' --output jsonpath="{.items[0].metadata.name}")
CONTAINER=rancher
EXECUTABLE=rancher

$(dirname $0)/../delve-debugger.sh ${NAMESPACE} ${POD} ${CONTAINER} ${EXECUTABLE}
