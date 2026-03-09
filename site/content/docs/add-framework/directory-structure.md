---
title: Directory Structure
---

Create a directory under `frameworks/` with your framework's name:

```
frameworks/
  your-framework/
    Dockerfile
    meta.json
    ... (source files)
```

## Dockerfile

The Dockerfile should build and run your server. Containers are started with `--network host`, so bind to:

- **Port 8080** — HTTP/1.1
- **Port 8443** — HTTPS with HTTP/2 and HTTP/3 (if supported)

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

## Mounted volumes

The benchmark runner mounts these paths into your container (read-only):

| Path | Purpose | When |
|------|---------|------|
| `/data/dataset.json` | 50-item dataset for `/json` endpoint | Always |
| `/data/dataset-large.json` | 6000-item dataset for `/compression` endpoint | If `compression` in tests |
| `/data/static/` | 20 static files (CSS, JS, HTML, fonts, images) | If `static-h2` or `static-h3` in tests |
| `/certs/server.crt` | TLS certificate | If any H2/H3 test in tests |
| `/certs/server.key` | TLS private key | If any H2/H3 test in tests |
