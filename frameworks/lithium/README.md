# lithium

Lithium C++ HTTP framework with compile-time reflection, boost::context coroutines, and aggressive optimizations.

## Stack

- **Language:** C++17
- **Framework:** Lithium (li/http)
- **Build:** `buildpack-deps:bookworm`, clang with `-O3 -march=native -flto -DNDEBUG`

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
| `/static` | GET | Serves preloaded static files |

## Notes

- Header-only library approach
- Custom JSON parser (no external JSON dependency)
- Boost.Context for stackful coroutines
- Per-worker SQLite connections
