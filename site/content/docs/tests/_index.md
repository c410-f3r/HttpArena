---
title: Test Profiles
---

HttpArena runs every framework through four distinct benchmark profiles. Each profile isolates a different performance dimension, ensuring frameworks are compared fairly across varied workloads.

Each profile is run at multiple connection counts to show how frameworks scale under increasing concurrency:

| Parameter | Value |
|-----------|-------|
| Connections | 512, 4,096, 16,384 (baseline & pipelined) / 512, 4,096 (others) |
| Threads | 12 |
| Duration | 5s |
| Runs | 3 (best taken) |
| Networking | Docker `--network host` |

## Baseline

The primary throughput benchmark. Each of the 512 connections sends one request at a time over persistent keep-alive connections with no CPU restrictions.

**Workload:** A mix of three request types, rotated across connections:

- `GET /bench?a=13&b=42` -- query parameter parsing, response: sum of values
- `POST /bench?a=13&b=42` with Content-Length body -- query params + body parsing
- `POST /bench?a=13&b=42` with chunked Transfer-Encoding body -- chunked decoding

This exercises the full HTTP handling path: request line parsing, header parsing, query string extraction, body reading (both Content-Length and chunked), integer arithmetic, and response serialization.

## Short-lived Connections (10 req/conn)

Same workload as baseline, but each connection is closed and re-established after 10 requests. This forces frequent TCP handshakes, measuring how efficiently a framework handles:

- Socket creation and teardown overhead
- Connection accept rate
- Per-connection memory allocation/deallocation
- Any connection pooling or caching strategies

Real-world relevance: many clients (mobile, IoT, load balancers without keepalive) don't maintain long-lived connections.

## CPU Limited (12 vCPU)

Same workload as baseline, but the server's Docker container is restricted to 12 vCPUs via `--cpus=12`. This reveals per-request CPU efficiency:

- Frameworks with lower overhead per request maintain higher throughput
- Highlights the cost of runtime features (GC, goroutine scheduling, JIT compilation)
- Shows how well a framework scales when CPU is the bottleneck rather than I/O

A framework that scores the same here as in baseline is not CPU-bound in either test.

## Pipelined (16x)

16 HTTP requests are sent back-to-back on each connection before waiting for responses. Uses a lightweight `GET /pipeline` endpoint that returns a fixed `ok` response, isolating raw I/O throughput from application logic.

This tests HTTP pipelining support and efficiency:

- Frameworks that parse multiple requests from a single read buffer gain a major advantage
- Frameworks processing one request at a time per connection see minimal improvement over baseline
- Measures network batching, write coalescing, and syscall reduction

**Why a separate endpoint?** The `/pipeline` endpoint removes application-level variance (query parsing, body handling) so the benchmark measures pure I/O and protocol handling throughput.
