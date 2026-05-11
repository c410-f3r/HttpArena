# roadrunner

[Roadrunner](https://github.com/arizona-framework/roadrunner) is the pure-Erlang HTTP/1.1 + HTTP/2 + WebSocket server from the Arizona framework. This entry packages a minimal OTP release wrapping roadrunner with the HttpArena endpoint contract.

## Profiles

Covered:

- `baseline`, `pipelined`, `limited-conn`
- `json`, `json-comp`, `json-tls`
- `upload`
- `async-db`, `api-4`, `api-16`
- `baseline-h2`
- `echo-ws`, `echo-ws-pipeline`

Deferred (tracked under [HttpArena coverage gaps](https://github.com/arizona-framework/roadrunner/blob/main/docs/roadmap.md) in the roadrunner roadmap):

- `static`, `static-h2`: roadrunner has a static handler; the bench app entry needs to wire it up and add gzip-sibling serving.
- `fortunes`, `crud`: bench-app endpoints, not roadrunner gaps.
- `baseline-h2c`, `json-h2c`: roadrunner is h2-over-TLS-only today; h2c (cleartext h2) is a roadrunner-side gap.
- `baseline-h3`, `static-h3`: roadrunner has no HTTP/3 stack yet.
- `unary-grpc`, `stream-grpc`, TLS variants: no gRPC stack.
- `gateway-64`, `gateway-h3`, `production-stack`: reverse-proxy multi-container scenarios; out of scope for the single-framework entry.

## Build

`docker build -t httparena-roadrunner frameworks/roadrunner` then run via `scripts/validate.sh roadrunner` from the repo root.
