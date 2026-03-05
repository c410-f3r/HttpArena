#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/.."
cd "$ROOT_DIR"

# If no argument, run all frameworks
if [ $# -eq 0 ]; then
    for fw in $(ls -d "$ROOT_DIR"/frameworks/*/ | xargs -n1 basename); do
        "$SCRIPT_DIR/benchmark.sh" "$fw"
    done
    exit 0
fi

FRAMEWORK="$1"
IMAGE_NAME="httparena-${FRAMEWORK}"
CONTAINER_NAME="httparena-bench-${FRAMEWORK}"
PORT=8080
GCANNON="${GCANNON:-/home/diogo/Desktop/Socket/gcannon/gcannon}"
RUNS=3
DURATION=5s
CONNS=512
THREADS=12
PIPELINE=1
REQUESTS_DIR="$SCRIPT_DIR/../requests"
RESULTS_DIR="$SCRIPT_DIR/../results"

cleanup() {
    docker rm -f "$CONTAINER_NAME" 2>/dev/null || true
}
trap cleanup EXIT

mkdir -p "$RESULTS_DIR"

echo "=== Benchmarking: $FRAMEWORK ==="

# Stop any httparena containers (running or stopped)
docker ps -aq --filter "name=httparena-" | xargs -r docker rm -f 2>/dev/null || true

# Build
echo "[build] Building Docker image..."
if [ -x "frameworks/$FRAMEWORK/build.sh" ]; then
    "frameworks/$FRAMEWORK/build.sh" || { echo "FAIL: Docker build failed"; exit 1; }
else
    docker build -t "$IMAGE_NAME" "frameworks/$FRAMEWORK" || { echo "FAIL: Docker build failed"; exit 1; }
fi

# Run (host networking for best performance, seccomp/memlock for io_uring)
docker run -d --name "$CONTAINER_NAME" --network host \
    --cpus=12 \
    --security-opt seccomp=unconfined \
    --ulimit memlock=-1:-1 \
    "$IMAGE_NAME"

# Wait for server
echo "[wait] Waiting for server..."
for i in $(seq 1 30); do
    if curl -s -o /dev/null --max-time 2 "http://localhost:$PORT/bench?a=1&b=1" 2>/dev/null; then
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
best_cpu="0%"

for run in $(seq 1 $RUNS); do
    echo ""
    echo "[run $run/$RUNS] Duration: $DURATION"

    # Sample CPU in background during the run
    cpu_log=$(mktemp)
    while true; do
        docker stats --no-stream --format '{{.CPUPerc}}' "$CONTAINER_NAME" >> "$cpu_log" 2>/dev/null
    done &
    cpu_pid=$!

    output=$("$GCANNON" "http://localhost:$PORT" \
        --raw "$REQUESTS_DIR/get.raw,$REQUESTS_DIR/post_cl.raw,$REQUESTS_DIR/post_chunked.raw" \
        -c "$CONNS" -t "$THREADS" -d "$DURATION" -p "$PIPELINE" 2>&1) || true

    kill "$cpu_pid" 2>/dev/null; wait "$cpu_pid" 2>/dev/null || true

    # Average CPU samples
    avg_cpu=$(awk -F'%' 'NF>0 && $1+0>0 {sum+=$1; n++} END{if(n>0) printf "%.1f%%", sum/n; else print "0%"}' "$cpu_log")
    rm -f "$cpu_log"

    echo "$output"
    echo "  CPU usage: $avg_cpu"

    # Extract RPS from exact request count: "17250904 requests in 5.00s"
    req_count=$(echo "$output" | grep -oP '(\d+) requests in' | grep -oP '\d+' || echo "0")
    duration_secs=$(echo "$output" | grep -oP 'requests in ([\d.]+)s' | grep -oP '[\d.]+' || echo "1")
    rps_int=$(echo "$req_count / $duration_secs" | bc | cut -d. -f1)
    rps_int=${rps_int:-0}

    if [ "$rps_int" -gt "$best_rps" ]; then
        best_rps=$rps_int
        best_output="$output"
        best_cpu="$avg_cpu"
    fi

    # Brief pause between runs
    sleep 2
done

echo ""
echo "=== Best run: ${best_rps} req/s (CPU: $best_cpu) ==="
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
  "cpu": "$best_cpu",
  "connections": $CONNS,
  "threads": $THREADS,
  "duration": "$DURATION",
  "pipeline": $PIPELINE
}
EOF

echo ""
echo "[saved] Results written to results/${FRAMEWORK}.json"

# Rebuild site/data/results.json from all result files
SITE_DATA="$ROOT_DIR/site/data"
mkdir -p "$SITE_DATA"
echo '[' > "$SITE_DATA/results.json"
first=true
for f in "$RESULTS_DIR"/*.json; do
    [ -f "$f" ] || continue
    $first || echo ',' >> "$SITE_DATA/results.json"
    cat "$f" >> "$SITE_DATA/results.json"
    first=false
done
echo ']' >> "$SITE_DATA/results.json"
echo "[updated] site/data/results.json"
