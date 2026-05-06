#!/bin/sh
set -eu

PORT="${PORT:-8080}"
WORKERS="${WORKERS:-$(nproc)}"
MODE="${DART_IO_MODE:-aot}"

if [ -f /lib/reuseport_shim.so ]; then
  export LD_PRELOAD=/lib/reuseport_shim.so
fi

if [ "$MODE" = "aot" ] && [ -f /app/benchmark_http_server.aot ]; then
  RUNTIME="/opt/dart-zig-sdk/out/ReleaseX64/dartaotruntime /app/benchmark_http_server.aot"
else
  RUNTIME="/opt/dart-zig-sdk/out/ReleaseX64/dart /app/benchmark_http_server.dill"
fi

echo "[dart-io] mode=${MODE} workers=${WORKERS} port=${PORT}"

if [ "${WORKERS}" -le 1 ]; then
  exec sh -c "$RUNTIME \"$PORT\""
fi

i=1
while [ "$i" -lt "${WORKERS}" ]; do
  sh -c "$RUNTIME \"$PORT\"" &
  i=$((i + 1))
done

exec sh -c "$RUNTIME \"$PORT\""
