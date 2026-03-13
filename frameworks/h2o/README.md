# h2o

High-performance C HTTP server using the libh2o library with multi-threaded event loops and native HTTP/2 support.

## Stack

- **Language:** C
- **Engine:** h2o
- **Build:** `buildpack-deps:bookworm` → `debian:bookworm-slim`, clang with `-flto=auto -march=native`

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
| `/upload` | POST | Receives 1 MB body, returns byte count |
| `/static` | GET | Serves preloaded static files (max 32) |

## Notes

- Custom C handler registered directly with h2o
- Thread-local SQLite connections with prepared statement caching
- yajl for JSON parsing
- Static files preloaded at startup with MIME type mapping
- HTTP/1.1 and HTTP/2 support
