#!/bin/bash
set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Port configuration (configurable via env var)
E2E_HOST_PORT="${E2E_HOST_PORT:-4000}"
E2E_TIMEOUT="${E2E_TIMEOUT_DOCKER:-30}"

# Image names
DELVE_DEBUGGER_IMAGE="ghcr.io/moio/delve-debugger"
TEST_TARGET_IMAGE="delve-debugger-test-target:latest"

# Read versions from Dockerfile
DLV_VERSION=$(grep '^ARG DLV_VERSION=' "$PROJECT_ROOT/package/Dockerfile" | cut -d'=' -f2)
DELVE_DEBUGGER_VERSION=$(grep '^ARG DELVE_DEBUGGER_VERSION=' "$PROJECT_ROOT/package/Dockerfile" | cut -d'=' -f2)
DELVE_DEBUGGER_TAG="$DLV_VERSION-$DELVE_DEBUGGER_VERSION"

# Cleanup function
cleanup() {
  echo "Cleaning up Docker test resources..."
  docker rm -f delve-test-target delve-debugger 2>/dev/null || true
}

trap cleanup EXIT

echo "=== Docker E2E Test ==="
echo "Port: $E2E_HOST_PORT"
echo "Timeout: ${E2E_TIMEOUT}s"
echo ""

# Start target container
echo "Starting target container..."
docker run -d --name delve-test-target "$TEST_TARGET_IMAGE"

# Wait for target to be running
sleep 2

# Run delve-debugger against it
echo "Starting delve-debugger (publishing on port $E2E_HOST_PORT)..."
docker run -d \
  --name delve-debugger \
  --privileged \
  --pid=container:delve-test-target \
  --env EXECUTABLE=testprogram \
  --publish $E2E_HOST_PORT:4000/tcp \
  "$DELVE_DEBUGGER_IMAGE:$DELVE_DEBUGGER_TAG"

# Wait for Delve to be ready
echo "Waiting for Delve to be ready..."
if bash "$SCRIPT_DIR/wait-for-delve.sh" 127.0.0.1 "$E2E_HOST_PORT" "$E2E_TIMEOUT"; then
  echo "✓ Docker test PASSED"
  exit 0
else
  echo "✗ Docker test FAILED"
  echo "Delve debugger logs:"
  docker logs delve-debugger 2>&1 || true
  exit 1
fi
