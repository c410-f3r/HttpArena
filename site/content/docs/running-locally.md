---
title: Running Locally
---

Run the full HttpArena benchmark suite on your own machine.

## Prerequisites

- **Docker** — each framework runs inside a container
- **gcannon** — the io_uring-based HTTP load generator ([GitHub](https://github.com/MDA2AV/gcannon))
- **Linux** — gcannon requires io_uring (kernel 5.6+)
- **curl** and **bc** — used by the benchmark script

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

## Running benchmarks

Run all frameworks across all profiles:

```bash
./scripts/benchmark.sh
```

Run a single framework:

```bash
./scripts/benchmark.sh ringzero
```

Run a single framework with a specific profile:

```bash
./scripts/benchmark.sh ringzero baseline
```

Available profiles: `baseline`, `pipelined`, `limited-conn`, `cpu-limited`.

## What happens

For each framework and profile combination, the script:

1. Builds the Docker image from `frameworks/<name>/Dockerfile`
2. Starts the container with `--network host`
3. Waits for the server to respond on port 8080
4. Runs gcannon 3 times and keeps the best result
5. Saves results to `results/<profile>/<connections>/<framework>.json`
6. Saves Docker logs to `site/static/logs/<profile>/<connections>/<framework>.log`
7. Rebuilds site data files in `site/data/`

## Configuration

Default parameters in `scripts/benchmark.sh`:

| Parameter | Default |
|-----------|---------|
| Threads | 12 |
| Duration | 5s per run |
| Runs | 3 (best taken) |
| Port | 8080 |

## Adding a framework

1. Create `frameworks/<name>/Dockerfile` that builds and runs your server on port 8080
2. Create `frameworks/<name>/meta.json` with display name, language, description, and repo URL
3. Implement the required endpoints: `GET/POST /bench?a=N&b=N` and `GET /pipeline`
4. Run `./scripts/benchmark.sh <name>` to test
