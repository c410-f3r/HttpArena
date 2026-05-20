# effinitive

Ultra-high-performance custom HTTP server for .NET 10 — built from scratch for maximum speed.

## Stack

- **Language:** C# / .NET 10
- **Framework:** Effinitive (custom, no Kestrel)
- **Engine:** Custom TCP server with System.IO.Pipelines
- **Build:** Self-contained single-file publish

## Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/pipeline` | GET | Returns `ok` (plain text) |
| `/baseline11` | GET | Sums query parameter values |
| `/baseline11` | POST | Sums query parameters + request body |
| `/baseline2` | GET | Sums query parameter values (HTTP/2 variant) |
| `/json` | GET | Processes 50-item dataset, serializes JSON |
| `/compression` | GET | Gzip-compressed large JSON response |
| `/db` | GET | SQLite range query with JSON response |
| `/async-db` | GET | PostgreSQL async queries |
| `/upload` | POST | Receives body, returns byte count |
| `/static/{filename}` | GET | Serves preloaded static files with MIME types |

## Architecture

- **Zero-allocation routing** — FrozenDictionary + Span<T> based, no string allocations
- **Custom HTTP parser** — RFC 9110/9112 compliant, SequenceReader<byte> based
- **HTTP/2 support** — ALPN negotiation, HPACK compression, binary framing
- **System.IO.Pipelines** — High-performance I/O with PipeReader/PipeWriter
- **Compiled endpoint invokers** — Expression trees eliminate per-request reflection
- **Pre-computed responses** — JSON and static files cached at startup
- **HTTP/1.1 on port 8080**, HTTP/1+2 on port 8443 with TLS
