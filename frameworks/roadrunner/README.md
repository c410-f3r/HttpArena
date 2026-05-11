# roadrunner

[Roadrunner](https://github.com/arizona-framework/roadrunner) is the pure-Erlang HTTP/1.1 + WebSocket server from the Arizona framework. This entry packages a minimal OTP release wrapping roadrunner with the HttpArena endpoint contract.

## Profiles

Covered:

- `baseline`, `pipelined`, `limited-conn`
- `json`, `json-comp`, `json-tls`
- `upload`
- `async-db`, `api-4`, `api-16`
- `echo-ws`, `echo-ws-pipeline`

Deferred:

- `static` — needs a static-file handler in roadrunner.
- `fortunes` — needs an HTML template story for roadrunner.
- `baseline-h2`, `static-h2`, `baseline-h2c`, `json-h2c`, `baseline-h3`, `static-h3` — roadrunner is HTTP/1.1 only today.
- `unary-grpc`, `stream-grpc` (+ TLS variants) — no gRPC stack.
- `crud`, `gateway-*`, `production-stack` — multi-container scenarios.

## Build

`docker build -t httparena-roadrunner frameworks/roadrunner` then run via `scripts/validate.sh roadrunner` from the repo root.
