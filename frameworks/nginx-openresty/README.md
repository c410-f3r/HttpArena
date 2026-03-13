# nginx-openresty

OpenResty (Nginx + LuaJIT) with Lua content handlers and FFI bindings to SQLite.

## Stack

- **Language:** Lua (LuaJIT)
- **Engine:** OpenResty (nginx)
- **Build:** `openresty/openresty:alpine` base

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
| `/static/{filename}` | GET | Serves preloaded static files |

## Notes

- FFI bindings to SQLite (raw `sqlite3_*` library calls)
- Per-worker database connection initialized in `init_worker` phase
- cjson for JSON processing
- Gzip compression at nginx server level
- Static files loaded into memory via Lua at startup
