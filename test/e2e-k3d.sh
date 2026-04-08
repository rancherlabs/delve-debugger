#!/bin/bash
set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Port configuration (configurable via env vars)
E2E_K3D_API_PORT="${E2E_K3D_API_PORT:-6443}"
E2E_K3D_DLV_PORT="${E2E_K3D_DLV_PORT:-14000}"
E2E_TIMEOUT="${E2E_TIMEOUT_K3D:-90}"
E2E_POD_READY_TIMEOUT="${E2E_POD_READY_TIMEOUT:-60s}"

# Image names
DELVE_DEBUGGER_IMAGE="ghcr.io/moio/delve-debugger"
TEST_TARGET_IMAGE="delve-debugger-test-target:latest"

# Read versions from Dockerfile
DLV_VERSION=$(grep '^ARG DLV_VERSION=' "$PROJECT_ROOT/package/Dockerfile" | cut -d'=' -f2)
DELVE_DEBUGGER_VERSION=$(grep '^ARG DELVE_DEBUGGER_VERSION=' "$PROJECT_ROOT/package/Dockerfile" | cut -d'=' -f2)
DELVE_DEBUGGER_TAG="$DLV_VERSION-$DELVE_DEBUGGER_VERSION"

# Check dependencies
if ! command -v k3d &> /dev/null; then
  echo "⊘ k3d not found, skipping k3d test"
  echo "  Install k3d: https://k3d.io/"
  exit 0
fi

if ! command -v kubectl &> /dev/null; then
  echo "⊘ kubectl not found, skipping k3d test"
  exit 0
fi

# Cleanup function
cleanup() {
  echo "Cleaning up k3d cluster..."
  k3d cluster delete delve-e2e-test 2>/dev/null || true
}

trap cleanup EXIT

echo "=== k3d E2E Test ==="
echo "API port: $E2E_K3D_API_PORT"
echo "Delve port: $E2E_K3D_DLV_PORT"
echo "Timeout: ${E2E_TIMEOUT}s"
echo "Pod ready timeout: $E2E_POD_READY_TIMEOUT"
echo ""

# Create k3d cluster with a fixed API port (needed when Docker runs on a remote host)
echo "Creating k3d cluster..."
k3d cluster create delve-e2e-test --no-lb --wait --api-port "0.0.0.0:$E2E_K3D_API_PORT"

# Patch kubeconfig to use 127.0.0.1 instead of localhost
# (avoids IPv6 resolution issues when Docker runs on a remote host with IPv4-only port forwarding)
kubectl config set-cluster k3d-delve-e2e-test --server="https://127.0.0.1:$E2E_K3D_API_PORT"

# Import images
echo "Importing images into k3d..."
k3d image import --cluster delve-e2e-test "$DELVE_DEBUGGER_IMAGE:$DELVE_DEBUGGER_TAG" "$TEST_TARGET_IMAGE"

# Deploy target pod
echo "Deploying target pod..."
kubectl apply -f "$SCRIPT_DIR/k8s/target-pod.yaml"

# Wait for pod to be ready
echo "Waiting for target pod to be ready (timeout: ${E2E_POD_READY_TIMEOUT})..."
if kubectl wait --for=condition=ready pod/delve-test-target --timeout="$E2E_POD_READY_TIMEOUT"; then
  echo "Target pod is ready"
else
  echo "✗ Target pod did not become ready within ${E2E_POD_READY_TIMEOUT}"
  echo "--- kubectl describe pod ---"
  kubectl describe pod/delve-test-target 2>&1 || true
  echo "--- kubectl get events ---"
  kubectl get events --sort-by='.lastTimestamp' 2>&1 || true
  exit 1
fi

# Attach ephemeral debug container (no -it since we run in background)
echo "Attaching ephemeral debug container..."
kubectl debug delve-test-target \
  --image="$DELVE_DEBUGGER_IMAGE:$DELVE_DEBUGGER_TAG" \
  --image-pull-policy=Never \
  --target=target \
  --profile=general \
  -- /bin/sh -c "EXECUTABLE=testprogram /usr/bin/entrypoint.sh" &

DEBUG_PID=$!

# Wait for the ephemeral container to start
echo "Waiting for debug container to start..."
sleep 10

# Port-forward in background
echo "Setting up port-forward..."
kubectl port-forward pod/delve-test-target "$E2E_K3D_DLV_PORT:4000" &
PF_PID=$!

# Ensure background processes are cleaned up
trap "kill $PF_PID $DEBUG_PID 2>/dev/null || true; wait $PF_PID $DEBUG_PID 2>/dev/null || true; cleanup" EXIT

# Wait a bit for port-forward to establish
sleep 3

# Wait for Delve to be ready
echo "Waiting for Delve to be ready..."
if bash "$SCRIPT_DIR/wait-for-delve.sh" 127.0.0.1 "$E2E_K3D_DLV_PORT" "$E2E_TIMEOUT"; then
  echo "✓ k3d test PASSED"
  exit 0
else
  echo "✗ k3d test FAILED"
  echo "Pod logs:"
  kubectl logs delve-test-target -c target 2>&1 || true
  echo "Debug container logs:"
  kubectl logs delve-test-target -c debugger-* 2>&1 || true
  exit 1
fi
