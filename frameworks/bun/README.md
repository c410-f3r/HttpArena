# bun

Bun's built-in HTTP server using the JavaScriptCore engine with `reusePort` for multi-core scaling.

## Stack

- **Language:** TypeScript
- **Runtime:** Bun (latest)
- **Engine:** JavaScriptCore
- **Build:** `oven/bun:latest` base

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

- Built-in SQLite via `bun:sqlite` (read-only)
- Dual server: HTTP on 8080, TLS on 8443
- Gzip compression level 1
- `reusePort` for kernel-level load balancing
