# ringzero

Custom C HTTP server built on Linux's `io_uring` interface. Uses a multi-reactor architecture with `liburing` for asynchronous I/O — no `epoll`, no thread-per-connection.

## Stack

- **Language:** C (GCC, `-O2 -march=native`)
- **I/O:** io_uring via liburing
- **Architecture:** 12 reactor threads, shared accept

## Endpoints

- `GET /pipeline` — returns `ok`, handles pipelined requests by scanning for multiple `\r\n\r\n` boundaries in a single read buffer
- `GET /bench?a=N&b=N` — sums query parameter values
- `POST /bench?a=N&b=N` — sums query parameters + request body (Content-Length and chunked)

## Notes

- Pipeline handler batches multiple responses per `read()` for maximum throughput
- Manual HTTP parsing with `memmem`/`memchr` — no framework overhead
- Chunked Transfer-Encoding decoded inline
- Runs on Ubuntu 24.04 with `liburing2`
