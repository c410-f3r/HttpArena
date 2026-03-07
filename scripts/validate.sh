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
if [ -x "frameworks/$FRAMEWORK/build.sh" ]; then
    "frameworks/$FRAMEWORK/build.sh" || { echo "FAIL: Docker build failed"; exit 1; }
else
    docker build -t "$IMAGE_NAME" "frameworks/$FRAMEWORK" || { echo "FAIL: Docker build failed"; exit 1; }
fi

# Run (mount dataset for /json endpoint)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/.."
docker run -d --name "$CONTAINER_NAME" -p "$PORT:8080" \
    -v "$ROOT_DIR/data/dataset.json:/data/dataset.json:ro" "$IMAGE_NAME"

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

# Test 4: GET /json (JSON processing endpoint)
# Check if framework subscribes to the json test
META_FILE="$ROOT_DIR/frameworks/$FRAMEWORK/meta.json"
if [ -f "$META_FILE" ] && grep -q '"json"' "$META_FILE"; then
    response=$(curl -s "http://localhost:$PORT/json")
    count=$(echo "$response" | grep -oP '"count"\s*:\s*\K\d+' || echo "0")
    has_total=$(echo "$response" | grep -q '"total"' && echo "yes" || echo "no")

    if [ "$count" = "50" ] && [ "$has_total" = "yes" ]; then
        echo "  PASS [GET /json]"
        PASS=$((PASS + 1))
    else
        echo "  FAIL [GET /json]: count=$count, has_total=$has_total"
        FAIL=$((FAIL + 1))
    fi
fi

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ] || exit 1
