#!/bin/sh
set -e

NAMESPACE=fleet-local
JOB=$(kubectl --namespace ${NAMESPACE} get job --selector="objectset.rio.cattle.io/hash" --output jsonpath="{.items[0].metadata.name}")
POD=$(kubectl --namespace ${NAMESPACE} get pod --selector="job-name=${JOB}" --output jsonpath="{.items[0].metadata.name}")
CONTAINER=fleet
EXECUTABLE=fleet
LOCAL_PORT="${1:-4000}"

$(dirname $0)/../delve-debugger.sh ${NAMESPACE} ${POD} ${CONTAINER} ${EXECUTABLE} ${LOCAL_PORT}
