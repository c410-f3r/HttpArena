---
title: Prerequisites
weight: 1
---

Required tools and system dependencies to run HttpArena benchmarks.

## Dependencies

- **Docker** — each framework runs inside a container
- **gcannon** — the io_uring-based HTTP/1.1 load generator ([GitHub](https://github.com/MDA2AV/gcannon))
- **h2load** — HTTP/2 load generator from nghttp2 (for `baseline-h2` and `static-h2` profiles)
- **oha** — HTTP/3 load generator with QUIC support (for `baseline-h3` and `static-h3` profiles) ([GitHub](https://github.com/hatoo/oha))
- **Linux** — gcannon requires io_uring (kernel 6.1+)
- **curl** and **bc** — used by the benchmark script

## Installing h2load

```bash
sudo apt install nghttp2-client
```

## Installing oha

```bash
cargo install oha
```
