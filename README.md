# HttpArena

HTTP framework benchmark platform. Who is the fastest?

## How it works

1. Submit a PR adding your framework under `frameworks/<name>/Dockerfile`
2. CI validates your implementation against the endpoint spec
3. Benchmarks run on a dedicated machine using [gcannon](https://github.com/MDA2AV/gcannon)
4. Results appear on the [leaderboard](https://MDA2AV.github.io/HttpArena/)

## Endpoint spec

Your server must listen on port **8080** and handle `GET` and `POST` requests to `/bench`.

### Request format

| Type | Example |
|------|---------|
| GET | `GET /bench?a=13&b=42` |
| POST + Content-Length | `POST /bench?a=13&b=42` with body `20` |
| POST + Chunked | `POST /bench?a=13&b=42` with chunked body `20` |

### Response requirements

- **Body**: plain text sum of all numbers (query params + body)
  - GET example: `55` (13 + 42)
  - POST example: `75` (13 + 42 + 20)
- **Headers**: must include a `Server` header (e.g., `Server: MyFramework`)

### Benchmark parameters

| Parameter | Value |
|-----------|-------|
| Connections | 512 |
| Threads | 12 |
| Pipeline | 1 |
| Req/conn | 100 |
| Duration | 30s |
| Runs | 3 (best taken) |

## Directory structure

```
frameworks/
  example-go/
    Dockerfile
    main.go
```

The Dockerfile must produce a container that starts your HTTP server on port 8080.

## Local testing

```bash
# Validate
./scripts/validate.sh example-go

# Benchmark
GCANNON=/path/to/gcannon ./scripts/benchmark.sh example-go
```
