# node

Bare Node.js HTTP server using the cluster module for multi-core scaling.

## Stack

- **Language:** JavaScript
- **Runtime:** Node.js 22
- **Engine:** V8
- **Build:** `node:22-slim` base

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

- Cluster module forks one worker per CPU core
- `better-sqlite3` for database access
- Per-worker database connections
- Gzip compression via `zlib` (level 1)
