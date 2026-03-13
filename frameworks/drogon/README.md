# drogon

Drogon C++ web framework with async callbacks, built with `-flto` and `-march=native` optimizations.

## Stack

- **Language:** C++17
- **Framework:** Drogon v1.9.10
- **Build:** Ubuntu 24.04, CMake, `-flto -march=native`

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

- Thread-local SQLite connections
- jsoncpp for JSON parsing/serialization
- Static files preloaded into memory at startup
- Multi-threaded event loop
