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

2. Build and install gcannon:

```bash
git clone https://github.com/MDA2AV/gcannon.git
cd gcannon
make
sudo cp gcannon /usr/local/bin/
```

Alternatively, if you prefer not to install system-wide, set the `GCANNON` environment variable:

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
