# go-fasthttp

HTTP server built with [fasthttp](https://github.com/valyala/fasthttp), a high-performance HTTP library for Go that avoids `net/http` overhead through zero-allocation design and buffer reuse.

## Stack

- **Runtime:** Go 1.22
- **Web server:** fasthttp
- **Routing:** Manual path switch

## Endpoints

- `GET /pipeline` — returns `ok` (plain text)
- `GET /bench?a=N&b=N` — sums query parameter values
- `POST /bench?a=N&b=N` — sums query parameters + request body (Content-Length and chunked)

## Notes

- fasthttp processes one request at a time per connection, so pipelining throughput gains are minimal
- Uses `VisitAll` for zero-copy query parameter iteration
- Statically compiled (`CGO_ENABLED=0`) with Alpine base image
