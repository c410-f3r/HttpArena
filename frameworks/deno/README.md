# deno

Deno HTTP server using `deno serve --parallel` with a zero-dependency native fetch handler.

## Stack

- **Language:** TypeScript
- **Runtime:** Deno 2.2.2
- **Engine:** V8
- **Build:** `denoland/deno:2.2.2` base

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

## Notes

- `deno serve --parallel` for multi-core scaling
- SQLite via `jsr:@db/sqlite@0.12`
- Gzip compression via Node.js zlib compat layer (level 1)
- Thread-local database connections
