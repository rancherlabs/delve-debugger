#!/bin/sh
set -e

NAMESPACE=cattle-fleet-local-system
POD=$(kubectl --namespace ${NAMESPACE} get pod --selector='app=fleet-agent' --output jsonpath="{.items[0].metadata.name}")
CONTAINER=fleet-agent
EXECUTABLE=fleetagent

$(dirname $0)/../delve-debugger.sh ${NAMESPACE} ${POD} ${CONTAINER} ${EXECUTABLE}
