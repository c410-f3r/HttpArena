---
title: Implementation Guidelines
---
{{< type-rules production="All endpoint implementations must follow their respective production rules. No endpoint-specific optimizations that would not be used in production." tuned="May optimize each endpoint independently. Pre-computed responses, custom serializers, and non-default configurations allowed." engine="No specific rules." >}}

The Mini profile runs the exact same workload as the [Mixed Workload](../../mixed/implementation) test but with the server container constrained to **4 CPUs and 16 GB memory**. The load generator also scales down to 4 threads and 128 connections.

**Connections:** 128

## How it differs from Mixed

| Parameter | Mixed | Mini |
|-----------|-------|------|
| Server CPUs | Unlimited | 4 |
| Server memory | Unlimited | 16 GB |
| Connections | 4,096 | 128 |
| gcannon threads | 64 | 4 |
| Duration | 15s | 15s |
| Request templates | 14 | 14 (same) |
| Requests per connection | 5 | 5 |

## What it measures

- **Resource-constrained performance** - how well a framework utilizes limited CPU and memory
- **Real-world relevance** - closer to a typical production deployment (4-core VM, limited RAM) than the full-hardware tests
- **Efficiency under contention** - thread pool saturation, memory pressure, and GC behavior when resources are scarce
- **Scaling characteristics** - whether a framework's performance degrades gracefully with fewer resources

## Request mix

The request mix is identical to Mixed:

- 3x baseline GET (`GET /baseline11?a=1&b=2`)
- 2x baseline POST (`POST /baseline11` with body)
- 1x JSON processing (`GET /json`)
- 1x SQLite DB query (`GET /db?min=10&max=50`)
- 1x file upload (`POST /upload` with 1 MB body)
- 2x gzip compression (`GET /compression` with `Accept-Encoding: gzip`)
- 2x static files (`GET /static/reset.css`, `GET /static/app.js`)
- 2x async DB query (`GET /async-db?min=10&max=50`)

See the [Mixed implementation guide](../../mixed/implementation) for full endpoint details, template rotation, and weighted scoring.

## Docker constraints

The server container is started with:

```
--cpus=4 --memory=16g --memory-swap=16g
```

If a framework exceeds the 16 GB memory limit, the container will be OOM-killed by Docker.

## Parameters

| Parameter | Value |
|-----------|-------|
| Endpoints | `/baseline11`, `/json`, `/db`, `/upload`, `/compression`, `/static/*`, `/async-db` |
| Connections | 128 |
| Pipeline | 1 |
| Requests per connection | 5 (then reconnect with next template) |
| Duration | 15s |
| Runs | 3 (best taken) |
| Templates | 14 (3 baseline GET, 2 baseline POST, 1 JSON, 1 DB, 1 upload, 2 compression, 2 static, 2 async-db) |
| Server CPU limit | 4 |
| Server memory limit | 16 GB |
| gcannon threads | 4 |
