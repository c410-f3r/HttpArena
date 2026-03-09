---
title: Setup
weight: 2
---

Clone the repository, build the load generator, and prepare TLS certificates.

## Clone and build

1. Clone the repository:

```bash
git clone https://github.com/MDA2AV/HttpArena.git
cd HttpArena
```

2. Build gcannon and note its path:

```bash
git clone https://github.com/MDA2AV/gcannon.git
cd gcannon
make
```

3. Set the gcannon path (or export it):

```bash
export GCANNON=/path/to/gcannon/gcannon
```

## TLS certificates

The repository includes self-signed TLS certificates in `certs/` for the HTTP/2 benchmark. These are automatically mounted into Docker containers by the benchmark script — no setup needed.

To regenerate them (optional):

```bash
openssl req -x509 -newkey rsa:2048 -keyout certs/server.key -out certs/server.crt \
  -days 365 -nodes -subj "/CN=localhost"
```
