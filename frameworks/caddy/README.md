# caddy

Caddy web server with a custom Go handler module for all benchmark endpoints, native HTTP/2 and HTTP/3 support.

## Stack

- **Language:** Go 1.24
- **Framework:** Caddy 2.9.1 + custom `httparena` module
- **Build:** `xcaddy` builder, `debian:bookworm-slim` runtime

## Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/pipeline` | GET | Returns `ok` (plain text) |
| `/baseline11` | GET/POST | Sums query parameter values (+ body for POST) |
| `/baseline2` | GET | Sums query parameter values (HTTP/2 variant) |
| `/json` | GET | Processes 50-item dataset, serializes JSON |
| `/compression` | GET | Gzip-compressed large JSON response |
| `/db` | GET | SQLite range query with JSON response |
| `/upload` | POST | Receives 1 MB body, returns byte count |
| `/static` | GET | Serves preloaded static files |

## Notes

- Custom Caddy module registered via `caddy.RegisterModule`
- Connection pool sized to `runtime.NumCPU()`
- Gzip encoding level 1 via Caddy config
- Both HTTP and HTTPS listeners via Caddyfile
