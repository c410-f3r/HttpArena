#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
HTT_ARENA_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
FRAMEWORK_IMAGE="httparena-dart-io"
BUILDER_IMAGE="${DART_IO_BUILDER_IMAGE:-ghcr.io/kartikey321/dart-zig-builder:sha-0ed2b90cc29c41b6069204d07626e01b5bf074f8}"

docker pull "$BUILDER_IMAGE"
docker build \
  -f "$SCRIPT_DIR/Dockerfile" \
  --build-arg BUILDER_IMAGE="$BUILDER_IMAGE" \
  -t "$FRAMEWORK_IMAGE" \
  "$HTT_ARENA_ROOT"
