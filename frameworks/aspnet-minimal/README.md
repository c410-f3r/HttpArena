# aspnet-minimal

Minimal ASP.NET Core HTTP server using .NET 10 with Kestrel and minimal API routing.

## Stack

- **Language:** C# / .NET 10 (Alpine)
- **Framework:** ASP.NET Core Minimal APIs
- **Engine:** Kestrel
- **Build:** Self-contained publish, `aspnet:10.0-alpine` runtime

## Endpoints

| Endpoint | Method | Description |
|---|---|---|
| `/pipeline` | GET | Returns `ok` (plain text) |
| `/baseline11` | GET | Sums query parameter values |
| `/baseline11` | POST | Sums query parameters + request body |
| `/baseline2` | GET | Sums query parameter values (HTTP/2 variant) |
| `/json/{count}` | GET | Returns `count` items from the preloaded dataset; honors `Accept-Encoding: gzip/br/deflate` for the `json-comp` profile |
| `/async-db` | GET | Postgres range query: `SELECT ... WHERE price BETWEEN $min AND $max LIMIT $limit` |
| `/upload` | POST | Streams the request body and returns the byte count |
| `/static/*` | GET | Serves files from `/data/static` via `MapStaticAssets` with precomputed ETags + compression |

## Notes

- HTTP/1.1 on port 8080, HTTP/1+2+3 on port 8443, h1+TLS on port 8081 (`json-tls` profile)
- Logging disabled (`ClearProviders()`) for throughput
- Response compression middleware (gzip, fastest level) drives `/json` encoding
- HTTP/2 tuned: 256 max streams, 2 MB connection window
- Postgres pooled via `Npgsql.NpgsqlDataSource` built from `DATABASE_URL`
- Source split: `Program.cs` (startup), `Handlers.cs` (routes), `AppData.cs` (dataset cache), `Models.cs` (DTOs)
