ARG BUILDER_IMAGE=ghcr.io/kartikey321/dart-zig-builder:sha-0ed2b90cc29c41b6069204d07626e01b5bf074f8
FROM ${BUILDER_IMAGE} AS build

COPY frameworks/dart-io/benchmark_http_server.dart /tmp/benchmark_http_server.dart
COPY frameworks/dart-io/benchmark_http_server.aot /tmp/benchmark_http_server.aot
RUN /opt/dart-zig-sdk/out/ReleaseX64/dart \
    --snapshot-kind=kernel \
    --snapshot=/tmp/benchmark_http_server.dill \
    /tmp/benchmark_http_server.dart

FROM ${BUILDER_IMAGE}

RUN apt-get update \
    && apt-get install -y --no-install-recommends gcc libc6-dev \
    && rm -rf /var/lib/apt/lists/*

COPY frameworks/dart-io/entrypoint.sh /entrypoint.sh
COPY frameworks/dart-io/reuseport_shim.c /tmp/reuseport_shim.c
COPY data/dataset.json /data/dataset.json
COPY --from=build /tmp/benchmark_http_server.dill /app/benchmark_http_server.dill
COPY --from=build /tmp/benchmark_http_server.aot /app/benchmark_http_server.aot
RUN gcc -shared -fPIC -O2 -o /lib/reuseport_shim.so /tmp/reuseport_shim.c -ldl \
    && rm -f /tmp/reuseport_shim.c \
    && chmod +x /entrypoint.sh

EXPOSE 8080
CMD ["/entrypoint.sh"]
