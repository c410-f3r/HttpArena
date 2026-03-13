# spring-jvm

Spring Boot with embedded Tomcat on JDK 21.

## Stack

- **Language:** Java 21
- **Framework:** Spring Boot (Spring MVC)
- **Engine:** Tomcat
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

- Spring MVC controller with `@RestController`
- Server-level gzip compression for `application/json`
- Static files preloaded into `ConcurrentHashMap` at startup
- SQLite JDBC with read-only connection
