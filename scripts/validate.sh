#!/usr/bin/env bash
set -euo pipefail

FRAMEWORK="$1"
IMAGE_NAME="httparena-${FRAMEWORK}"
CONTAINER_NAME="httparena-validate-${FRAMEWORK}"
PORT=8080
PASS=0
FAIL=0

cleanup() {
    docker rm -f "$CONTAINER_NAME" 2>/dev/null || true
}
trap cleanup EXIT

echo "=== Validating: $FRAMEWORK ==="

# Build
echo "[build] Building Docker image..."
docker build -t "$IMAGE_NAME" "frameworks/$FRAMEWORK" || { echo "FAIL: Docker build failed"; exit 1; }

# Run
docker run -d --name "$CONTAINER_NAME" -p "$PORT:8080" "$IMAGE_NAME"

# Wait for server to start
echo "[wait] Waiting for server..."
for i in $(seq 1 30); do
    if curl -s -o /dev/null -w '' "http://localhost:$PORT/bench?a=1&b=1" 2>/dev/null; then
        break
    fi
    if [ "$i" -eq 30 ]; then
        echo "FAIL: Server did not start within 30s"
        exit 1
    fi
    sleep 1
done
echo "[ready] Server is up"

check() {
    local label="$1"
    local expected_body="$2"
    shift 2
    local response
    response=$(curl -s -D- "$@")
    local body
    body=$(echo "$response" | tail -1)
    local server_hdr
    server_hdr=$(echo "$response" | grep -i "^server:" || true)

    local ok=true

    if [ "$body" != "$expected_body" ]; then
        echo "  FAIL [$label]: expected body '$expected_body', got '$body'"
        ok=false
    fi

    if [ -z "$server_hdr" ]; then
        echo "  FAIL [$label]: missing Server header in response"
        ok=false
    fi

    if $ok; then
        echo "  PASS [$label]"
        PASS=$((PASS + 1))
    else
        FAIL=$((FAIL + 1))
    fi
}

# Test 1: GET with query params
check "GET /bench?a=13&b=42" "55" "http://localhost:$PORT/bench?a=13&b=42"

# Test 2: POST with Content-Length body
check "POST /bench?a=13&b=42 + CL body=20" "75" \
    -X POST -H "Content-Type: text/plain" -d "20" "http://localhost:$PORT/bench?a=13&b=42"

# Test 3: POST with chunked body
check "POST /bench?a=13&b=42 + chunked body=20" "75" \
    -X POST -H "Content-Type: text/plain" -H "Transfer-Encoding: chunked" -d "20" \
    "http://localhost:$PORT/bench?a=13&b=42"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ] || exit 1
