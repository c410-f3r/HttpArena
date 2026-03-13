# spring-jvm-jetty

Spring Boot with embedded Jetty 12 on JDK 21, supporting HTTP/1.1 and HTTP/2.

## Stack

- **Language:** Java 21
- **Framework:** Spring Boot (Spring MVC)
- **Engine:** Jetty 12
- **Build:** `maven:3.9-eclipse-temurin-21` → `eclipse-temurin:21-jre` runtime

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

- Jetty servlet container instead of default Tomcat
- OpenSSL available for TLS cert operations
- Custom `entrypoint.sh` for cert handling
- Shares `BenchmarkController` with spring-jvm
