# nginx

Nginx with a custom C handler module (`ngx_http_httparena_module`) compiled with `-O3 -march=native`. Supports HTTP/2 and HTTP/3 via quictls.

## Stack

- **Language:** C
- **Engine:** nginx 1.26.2
- **TLS:** quictls (OpenSSL fork for QUIC)
- **Build:** Debian bookworm, compiles nginx + quictls from source

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

- Custom C module using cJSON for JSON serialization
- Worker processes auto-configured to CPU count
- 65536 worker connections per process
- HTTP/1.1, HTTP/2, and HTTP/3 support
- Read-only SQLite access
- Gzip compression at server level
