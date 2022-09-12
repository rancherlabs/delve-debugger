#!/bin/sh
set -e

NAMESPACE=cattle-fleet-system
POD=$(kubectl --namespace ${NAMESPACE} get pod --selector='app=gitjob' --output jsonpath="{.items[0].metadata.name}")
CONTAINER=gitjob
EXECUTABLE=gitjob

$(dirname $0)/../delve-debugger.sh ${NAMESPACE} ${POD} ${CONTAINER} ${EXECUTABLE}
