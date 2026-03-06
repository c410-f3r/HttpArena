# aspnet-minimal

Minimal ASP.NET Core HTTP server using .NET 10 preview. Uses the built-in Kestrel web server with minimal API routing.

## Stack

- **Runtime:** .NET 10 (preview, Alpine)
- **Web server:** Kestrel (ASP.NET Core built-in)
- **Routing:** Minimal API (`MapGet`/`MapPost`)

## Endpoints

- `GET /pipeline` — returns `ok` (plain text)
- `GET /bench?a=N&b=N` — sums query parameter values
- `POST /bench?a=N&b=N` — sums query parameters + request body (Content-Length and chunked)

## Notes

- Logging is disabled (`ClearProviders()`) for maximum throughput
- Uses `StreamReader` for async body reading
- Single-file implementation in `Program.cs`
