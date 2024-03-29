#!/bin/bash
set -e

NAMESPACE=cattle-system
POD=$(kubectl --namespace ${NAMESPACE} get pod --selector='app=rancher' --output jsonpath="{.items[0].metadata.name}")
CONTAINER=rancher
EXECUTABLE=rancher
LOCAL_PORT="${1:-4000}"

$(dirname $0)/../delve-debugger.sh ${NAMESPACE} ${POD} ${CONTAINER} ${EXECUTABLE} ${LOCAL_PORT}
