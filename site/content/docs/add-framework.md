---
title: Add a Framework
---

Adding a framework to HttpArena takes three steps: create a Dockerfile, add metadata, and implement the required endpoints.

## 1. Create the framework directory

```
frameworks/
  your-framework/
    Dockerfile
    meta.json
    ... (source files)
```

## 2. Implement the endpoints

Your server must listen on **port 8080** (HTTP/1.1) and handle these endpoints:

### `GET/POST /baseline11?a=N&b=N`

Parse query parameters `a` and `b`, compute their sum, and return it as the response body.

For POST requests, the server must accept both:
- **Content-Length** bodies
- **Chunked Transfer-Encoding** bodies

Example requests:
```
GET /baseline11?a=13&b=42 HTTP/1.1
Host: localhost:8080
```

```
POST /baseline11?a=13&b=42 HTTP/1.1
Host: localhost:8080
Content-Length: 2

20
```

Expected response body for GET: `55` (13 + 42)
Expected response body for POST: `75` (13 + 42 + 20)

### `GET /pipeline`

Return a fixed `OK` response (exactly 2 bytes). This endpoint is used for the pipelined benchmark and should be as lightweight as possible — no query parsing or body handling.

### `GET /json`

Load the dataset from `/data/dataset.json` at startup (mounted by the benchmark runner). For each request, compute a `total` field (`price * quantity`) for every item and return the full result as JSON:

```json
{
  "items": [
    {"id": 1, "name": "Alpha Widget", "category": "electronics", "price": 29.99, "quantity": 5, "active": true, "tags": ["fast", "new"], "rating": {"score": 4.2, "count": 127}, "total": 149.95}
  ],
  "count": 50
}
```

The response must have `Content-Type: application/json`. The `total` field must be computed per-request — do not cache the serialized response.

### `GET /baseline2?a=N&b=N` (HTTP/2)

Same logic as `/baseline11` — parse query parameters and return their sum. This endpoint is served over **HTTPS on port 8443** using HTTP/2 with TLS.

To support this:
- Read TLS certificate and key from `/certs/server.crt` and `/certs/server.key` (mounted by the benchmark runner)
- Listen on port 8443 with HTTP/2 and TLS enabled
- The certs directory is mounted read-only into the container

This is optional — only add `baseline-h2` to your `tests` array if your framework supports HTTP/2.

## 3. Write the Dockerfile

The Dockerfile should build and run your server. It will be started with `--network host`, so bind to port 8080 (and 8443 for HTTP/2).

Example (Go):
```dockerfile
FROM golang:1.22-alpine AS build
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o server .

FROM alpine:3.19
COPY --from=build /app/server /server
CMD ["/server"]
```

## 4. Add metadata

Create `meta.json` in your framework directory:

```json
{
  "display_name": "your-framework",
  "language": "Go",
  "type": "realistic",
  "description": "Short description of the framework and its key features.",
  "repo": "https://github.com/org/repo",
  "enabled": true,
  "tests": ["baseline", "pipelined", "limited-conn", "json", "baseline-h2"]
}
```

| Field | Description |
|-------|-------------|
| `display_name` | Name shown in the leaderboard |
| `language` | Programming language |
| `type` | `realistic` for production-ready frameworks, `stripped` for custom/bare-metal implementations |
| `description` | Shown in the framework detail popup |
| `repo` | Link to the framework's source repository |
| `enabled` | Set to `false` to skip this framework during benchmark runs |
| `tests` | Array of test profiles this framework participates in. Available: `baseline`, `pipelined`, `limited-conn`, `json`, `baseline-h2` |

## 5. Test locally

```bash
./scripts/benchmark.sh your-framework baseline
```

This builds the Docker image, starts the container, runs the baseline benchmark, and saves results.

## 6. Submit a PR

Once your framework passes the benchmark, open a pull request to [HttpArena](https://github.com/MDA2AV/HttpArena) with your `frameworks/your-framework/` directory.
