# salvo

Salvo web framework on Tokio async runtime with rustls for TLS support, compiled with thin LTO.

## Stack

- **Language:** Rust 1.88
- **Framework:** Salvo
- **TLS:** rustls
- **Build:** Multi-stage, `debian:bookworm-slim` runtime, `-C target-cpu=native`

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
| `/static/{filename}` | GET | Serves preloaded static files with MIME types |

## Notes

- Thread-local SQLite connections
- Compression middleware enabled
- Static files preloaded into memory via `OnceLock`
- Tokio multi-threaded async runtime
