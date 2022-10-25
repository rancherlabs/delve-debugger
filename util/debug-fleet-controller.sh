#!/bin/sh
set -e

if kubectl get ns | grep cattle-fleet-system; then
  NAMESPACE=cattle-fleet-system
else
  NAMESPACE=fleet-system
fi
POD=$(kubectl --namespace ${NAMESPACE} get pod --selector='app=fleet-controller' --output jsonpath="{.items[0].metadata.name}")
CONTAINER=fleet-controller
EXECUTABLE=fleetcontroller
LOCAL_PORT="${1:-4000}"

$(dirname $0)/../delve-debugger.sh ${NAMESPACE} ${POD} ${CONTAINER} ${EXECUTABLE} ${LOCAL_PORT}
