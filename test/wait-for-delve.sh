#!/bin/bash
set -e

HOST="${1:-127.0.0.1}"
PORT="${2:-4000}"
TIMEOUT="${3:-30}"

echo "Waiting for Delve to be ready at $HOST:$PORT (timeout: ${TIMEOUT}s)..."

# Probe Delve via raw TCP JSON-RPC.
# Delve's headless API speaks raw JSON-RPC over TCP (Go net/rpc jsonrpc codec),
# NOT JSON-RPC over HTTP — so curl cannot be used here.
# Uses bash's built-in /dev/tcp for zero external dependencies.
probe_delve() {
  local response

  # Open TCP connection on file descriptor 3
  exec 3<>/dev/tcp/$HOST/$PORT 2>/dev/null || return 1

  # Send JSON-RPC request (Go's json.Encoder appends newline)
  echo '{"method":"RPCServer.State","params":[{"NonBlocking":true}],"id":1}' >&3 || { exec 3>&-; return 1; }

  # Read response with 3-second timeout
  read -t 3 response <&3 || { exec 3>&-; return 1; }

  # Close connection
  exec 3>&-

  # Validate response: must have our request id AND contain State.Running field
  # (proves Delve successfully attached to the target process)
  [[ "$response" == *'"id":1'* ]] && [[ "$response" == *'"Running":'* ]]
}

start_time=$(date +%s)
attempts=0
while true; do
  current_time=$(date +%s)
  elapsed=$((current_time - start_time))
  attempts=$((attempts + 1))

  if [ "$elapsed" -ge "$TIMEOUT" ]; then
    echo "ERROR: Timeout after ${elapsed}s / $attempts attempts waiting for Delve at $HOST:$PORT"
    exit 1
  fi

  if probe_delve; then
    echo "Delve API is responding correctly (after ${elapsed}s / $attempts attempts)"
    exit 0
  fi

  # Show progress every 5 seconds
  if [ $((attempts % 5)) -eq 0 ]; then
    echo "  Still waiting... (${elapsed}s elapsed)"
  fi

  sleep 1
done
