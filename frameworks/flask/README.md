# flask

Flask web framework on Gunicorn with sync workers, scaled to available CPU cores.

## Stack

- **Language:** Python 3.13
- **Framework:** Flask
- **WSGI server:** Gunicorn (sync workers)
- **Build:** `python:3.13-slim` base

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

- Workers = `os.sched_getaffinity(0) * 2` (respects Docker CPU limits)
- Thread-local SQLite connections via `threading.local()`
- Gzip compression level 1
- Keepalive timeout 120s
