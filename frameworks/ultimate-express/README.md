# ultimate-express

Express API reimplemented on uWebSockets.js for high performance, with cluster module for multi-core scaling.

## Stack

- **Language:** JavaScript
- **Runtime:** Node.js 22
- **Framework:** ultimate-express (Express on uWebSockets.js)
- **Build:** Multi-stage, `node:22` build → `ubuntu:24.04` runtime

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

## Notes

- Cluster module forks one worker per CPU core
- `better-sqlite3` for database access
- Per-worker database connections
- Express.js-compatible routing API
