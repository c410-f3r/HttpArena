---
title: Test Profiles
toc: false
---

HttpArena runs every framework through multiple benchmark profiles. Each profile isolates a different performance dimension, ensuring frameworks are compared fairly across varied workloads.

Each profile is run at multiple connection counts to show how frameworks scale under increasing concurrency:

| Parameter | Value |
|-----------|-------|
| Threads | 12 |
| Duration | 5s |
| Runs | 3 (best taken) |
| Networking | Docker `--network host` |

{{< cards >}}
  {{< card link="baseline" title="Baseline" subtitle="Primary throughput benchmark with persistent keep-alive connections and mixed GET/POST workload." icon="lightning-bolt" >}}
  {{< card link="baseline-h2" title="Baseline (HTTP/2)" subtitle="Same workload as baseline over encrypted HTTP/2 connections with TLS and stream multiplexing." icon="globe-alt" >}}
  {{< card link="static-h2" title="Static Files (HTTP/2)" subtitle="Serves 20 static files of various types over HTTP/2 with multiplexed streams, simulating a browser page load." icon="photograph" >}}
  {{< card link="short-lived" title="Short-lived Connection" subtitle="Connections closed after 10 requests, measuring TCP handshake and connection setup overhead." icon="refresh" >}}
  {{< card link="json-processing" title="JSON Processing" subtitle="Loads a dataset, computes derived fields, and serializes a JSON response — testing real-world API workloads." icon="document-text" >}}
  {{< card link="pipelined" title="Pipelined (16x)" subtitle="16 requests sent back-to-back per connection, testing raw I/O and pipeline batching." icon="fast-forward" >}}
{{< /cards >}}
