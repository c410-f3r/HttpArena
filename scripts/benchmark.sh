#!/usr/bin/env bash
set -euo pipefail

FRAMEWORK="$1"
IMAGE_NAME="httparena-${FRAMEWORK}"
CONTAINER_NAME="httparena-bench-${FRAMEWORK}"
PORT=8080
GCANNON="${GCANNON:-gcannon}"
RUNS=3
DURATION=30s
CONNS=512
THREADS=12
PIPELINE=1
REQ_PER_CONN=100
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REQUESTS_DIR="$SCRIPT_DIR/../requests"
RESULTS_DIR="$SCRIPT_DIR/../results"

cleanup() {
    docker rm -f "$CONTAINER_NAME" 2>/dev/null || true
}
trap cleanup EXIT

mkdir -p "$RESULTS_DIR"

echo "=== Benchmarking: $FRAMEWORK ==="

# Build
echo "[build] Building Docker image..."
docker build -t "$IMAGE_NAME" "frameworks/$FRAMEWORK" || { echo "FAIL: Docker build failed"; exit 1; }

# Run (host networking for best performance)
docker run -d --name "$CONTAINER_NAME" --network host "$IMAGE_NAME"

# Wait for server
echo "[wait] Waiting for server..."
for i in $(seq 1 30); do
    if curl -s -o /dev/null "http://localhost:$PORT/bench?a=1&b=1" 2>/dev/null; then
        break
    fi
    if [ "$i" -eq 30 ]; then
        echo "FAIL: Server did not start within 30s"
        exit 1
    fi
    sleep 1
done
echo "[ready] Server is up"

# Run best-of-3
best_rps=0
best_output=""

for run in $(seq 1 $RUNS); do
    echo ""
    echo "[run $run/$RUNS] Duration: $DURATION"

    output=$("$GCANNON" "http://localhost:$PORT" \
        --raw "$REQUESTS_DIR/get.raw,$REQUESTS_DIR/post_cl.raw,$REQUESTS_DIR/post_chunked.raw" \
        -c "$CONNS" -t "$THREADS" -d "$DURATION" -p "$PIPELINE" -r "$REQ_PER_CONN" 2>&1)

    echo "$output"

    # Extract RPS
    rps=$(echo "$output" | grep "Throughput:" | grep -oP '[\d.]+' | head -1)
    rps_int=${rps%%.*}

    if [ "$rps_int" -gt "$best_rps" ]; then
        best_rps=$rps_int
        best_output="$output"
    fi

    # Brief pause between runs
    sleep 2
done

echo ""
echo "=== Best run: ${best_rps} req/s ==="
echo "$best_output"

# Extract metrics from best run
avg_lat=$(echo "$best_output" | grep "Latency" | awk '{print $2}')
p50_lat=$(echo "$best_output" | grep "Latency" | awk '{print $3}')
p99_lat=$(echo "$best_output" | grep "Latency" | awk '{print $5}')

# Save results as JSON
cat > "$RESULTS_DIR/${FRAMEWORK}.json" <<EOF
{
  "framework": "$FRAMEWORK",
  "rps": $best_rps,
  "avg_latency": "$avg_lat",
  "p50_latency": "$p50_lat",
  "p99_latency": "$p99_lat",
  "connections": $CONNS,
  "threads": $THREADS,
  "duration": "$DURATION",
  "pipeline": $PIPELINE,
  "req_per_conn": $REQ_PER_CONN
}
EOF

echo ""
echo "[saved] Results written to results/${FRAMEWORK}.json"
