#!/bin/sh
set -e

NAMESPACE=cattle-fleet-system
POD=$(kubectl --namespace ${NAMESPACE} get pod --selector='app=fleet-controller' --output jsonpath="{.items[0].metadata.name}")
CONTAINER=fleet-controller
EXECUTABLE=fleetcontroller

$(dirname $0)/../delve-debugger.sh ${NAMESPACE} ${POD} ${CONTAINER} ${EXECUTABLE}
