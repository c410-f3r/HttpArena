---
title: Running Locally
---

Run the full HttpArena benchmark suite on your own machine.

## Prerequisites

- **Docker** — each framework runs inside a container
- **gcannon** — the io_uring-based HTTP load generator ([GitHub](https://github.com/MDA2AV/gcannon))
- **h2load** — HTTP/2 load generator from nghttp2 (for the `baseline-h2` profile)
- **Linux** — gcannon requires io_uring (kernel 5.6+)
- **curl** and **bc** — used by the benchmark script

### Installing h2load

```bash
sudo apt install nghttp2-client
```

## Setup

1. Clone the repository:

```bash
git clone https://github.com/MDA2AV/HttpArena.git
cd HttpArena
```

2. Build gcannon and note its path:

```bash
git clone https://github.com/MDA2AV/gcannon.git
cd gcannon
make
```

3. Set the gcannon path (or export it):

```bash
export GCANNON=/path/to/gcannon/gcannon
```

## TLS certificates

The repository includes self-signed TLS certificates in `certs/` for the HTTP/2 benchmark. These are automatically mounted into Docker containers by the benchmark script — no setup needed.

To regenerate them (optional):

```bash
openssl req -x509 -newkey rsa:2048 -keyout certs/server.key -out certs/server.crt \
  -days 365 -nodes -subj "/CN=localhost"
```

## Running benchmarks

Run all frameworks across all profiles:

```bash
./scripts/benchmark.sh
```

Run a single framework:

```bash
./scripts/benchmark.sh aspnet-minimal
```

Run a single framework with a specific profile:

```bash
./scripts/benchmark.sh aspnet-minimal baseline
```

Available profiles: `baseline`, `pipelined`, `limited-conn`, `json`, `baseline-h2`.

## What happens

For each framework and profile combination, the script:

1. Builds the Docker image from `frameworks/<name>/Dockerfile`
2. Starts the container with `--network host`
3. Waits for the server to respond
4. Runs the load generator 3 times and keeps the best result
5. Saves results to `results/<profile>/<connections>/<framework>.json`
6. Saves Docker logs to `site/static/logs/<profile>/<connections>/<framework>.log`
7. Rebuilds site data files in `site/data/`

For HTTP/1.1 profiles (`baseline`, `pipelined`, `limited-conn`, `json`), the load generator is **gcannon**. For `baseline-h2`, the load generator is **h2load**.

## Configuration

Default parameters in `scripts/benchmark.sh`:

| Parameter | Default |
|-----------|---------|
| Threads | 12 |
| Duration | 5s per run |
| Runs | 3 (best taken) |
| HTTP/1.1 port | 8080 |
| HTTP/2 port | 8443 (TLS) |
