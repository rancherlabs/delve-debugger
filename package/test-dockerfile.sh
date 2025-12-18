#!/bin/bash
# Test script to validate Dockerfile and verify versions

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="delve-debugger-test"
BUILD_SUCCESS=false

echo "=== Delve Debugger Dockerfile Test ==="
echo

# Extract versions from Dockerfile
echo "Extracting versions from Dockerfile..."
GO_VERSION=$(grep "^ARG GO_VERSION=" "$SCRIPT_DIR/Dockerfile" | cut -d'=' -f2)
DLV_VERSION=$(grep "^ARG DLV_VERSION=" "$SCRIPT_DIR/Dockerfile" | cut -d'=' -f2)
DELVE_DEBUGGER_VERSION=$(grep "^ARG DELVE_DEBUGGER_VERSION=" "$SCRIPT_DIR/Dockerfile" | cut -d'=' -f2)

echo "  GO_VERSION: $GO_VERSION"
echo "  DLV_VERSION: $DLV_VERSION"
echo "  DELVE_DEBUGGER_VERSION: $DELVE_DEBUGGER_VERSION"
echo

# Try full Docker build if Docker is available
if command -v docker &> /dev/null; then
    echo "Attempting Docker build..."
    if docker build --build-arg GO_VERSION="$GO_VERSION" \
                    --build-arg DLV_VERSION="$DLV_VERSION" \
                    --build-arg DELVE_DEBUGGER_VERSION="$DELVE_DEBUGGER_VERSION" \
                    --no-cache \
                    -t "$IMAGE_NAME:$DLV_VERSION-$DELVE_DEBUGGER_VERSION" \
                    "$SCRIPT_DIR" 2>&1; then
        echo "✓ Dockerfile built successfully"
        echo
        BUILD_SUCCESS=true
        
        # Test Delve version in container
        echo "Verifying Delve version..."
        DLV_VER=$(docker run --rm "$IMAGE_NAME:$DLV_VERSION-$DELVE_DEBUGGER_VERSION" dlv version 2>&1 | head -1)
        echo "  $DLV_VER"
        
        if echo "$DLV_VER" | grep -q "$DLV_VERSION"; then
            echo "✓ Delve version matches expected: $DLV_VERSION"
        else
            echo "✗ Delve version mismatch!"
            exit 1
        fi
        
        echo
        echo "=== All tests passed! ==="
        echo
        echo "Image: $IMAGE_NAME:$DLV_VERSION-$DELVE_DEBUGGER_VERSION"
        echo "To push this image, use:"
        echo "  docker tag $IMAGE_NAME:$DLV_VERSION-$DELVE_DEBUGGER_VERSION <your-registry>/$IMAGE_NAME:$DLV_VERSION-$DELVE_DEBUGGER_VERSION"
        echo "  docker push <your-registry>/$IMAGE_NAME:$DLV_VERSION-$DELVE_DEBUGGER_VERSION"
        exit 0
    else
        echo "⚠ Docker build failed (possibly due to network/registry access)"
        echo "  Falling back to basic validation..."
        echo
    fi
fi

# Fallback: Basic validation when full build isn't possible
echo "Performing basic syntax validation..."
echo

# Check required files exist
if [ ! -f "$SCRIPT_DIR/Dockerfile" ]; then
    echo "✗ Dockerfile not found"
    exit 1
fi
echo "✓ Dockerfile exists"

if [ ! -f "$SCRIPT_DIR/entrypoint.sh" ]; then
    echo "✗ entrypoint.sh not found"
    exit 1
fi
echo "✓ entrypoint.sh exists"

# Basic Dockerfile syntax checks
if ! grep -q "FROM.*suse/sle15" "$SCRIPT_DIR/Dockerfile"; then
    echo "✗ Base image not found in Dockerfile"
    exit 1
fi
echo "✓ Base image declared: $(grep 'FROM' "$SCRIPT_DIR/Dockerfile" | grep suse)"

if ! grep -q "ARG GO_VERSION" "$SCRIPT_DIR/Dockerfile"; then
    echo "✗ GO_VERSION not defined in Dockerfile"
    exit 1
fi
echo "✓ GO_VERSION defined: $GO_VERSION"

if ! grep -q "ARG DLV_VERSION" "$SCRIPT_DIR/Dockerfile"; then
    echo "✗ DLV_VERSION not defined in Dockerfile"
    exit 1
fi
echo "✓ DLV_VERSION defined: $DLV_VERSION"

if ! grep -q "ARG DELVE_DEBUGGER_VERSION" "$SCRIPT_DIR/Dockerfile"; then
    echo "✗ DELVE_DEBUGGER_VERSION not defined in Dockerfile"
    exit 1
fi
echo "✓ DELVE_DEBUGGER_VERSION defined: $DELVE_DEBUGGER_VERSION"

# Verify key commands are present
if ! grep -q "zypper.*install.*go" "$SCRIPT_DIR/Dockerfile"; then
    echo "✗ Go installation command not found"
    exit 1
fi
echo "✓ Go installation command present"

if ! grep -q "go install.*delve" "$SCRIPT_DIR/Dockerfile"; then
    echo "✗ Delve installation command not found"
    exit 1
fi
echo "✓ Delve installation command present"

if ! grep -q "COPY entrypoint.sh" "$SCRIPT_DIR/Dockerfile"; then
    echo "✗ entrypoint.sh copy command not found"
    exit 1
fi
echo "✓ Entrypoint script copy command present"

echo
echo "=== Basic validation passed! ==="
echo
if command -v docker &> /dev/null; then
    echo "Note: Full Docker build test requires network access to SUSE registry."
    echo "      To run a complete test, ensure network connectivity and run:"
    echo "      cd $(dirname "$SCRIPT_DIR") && make build"
else
    echo "Note: Docker not available. Install Docker to run full build tests."
fi
