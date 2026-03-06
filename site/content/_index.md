---
title: HttpArena
layout: hextra-home
---

{{< hextra/hero-badge link="https://github.com/MDA2AV/HttpArena" >}}
  <span>Open Source</span>
  {{< icon name="arrow-circle-right" attributes="height=14" >}}
{{< /hextra/hero-badge >}}

<div class="hx-mt-6 hx-mb-6">
{{< hextra/hero-headline >}}
  HTTP Framework&nbsp;Benchmark Arena
{{< /hextra/hero-headline >}}
</div>

<div class="hx-mb-12">
{{< hextra/hero-subtitle >}}
  An open benchmarking platform that measures HTTP framework performance under realistic workloads using io_uring-based load generation. Add your framework, get results automatically.
{{< /hextra/hero-subtitle >}}
</div>

<div style="height:20px"></div>

{{< cards >}}
  {{< card link="leaderboard" title="Leaderboard" subtitle="See which frameworks handle the most requests per second, ranked by throughput." icon="chart-bar" >}}
  {{< card link="https://mda2av.github.io/Http11Probe/" title="Compliance & Security" subtitle="HTTP/1.1 compliance testing — RFC conformance, request smuggling vectors, and malformed input handling." icon="shield-check" >}}
  {{< card link="https://github.com/MDA2AV/HttpArena" title="Contribute" subtitle="Add your framework with a Dockerfile and open a PR. Three steps to join the arena." icon="plus-circle" >}}
{{< /cards >}}

<div style="height:60px"></div>

<h2 style="font-size:2rem;font-weight:800;">How It Works</h2>

<div style="height:16px"></div>

Each framework runs inside a Docker container with host networking. A custom io_uring HTTP load generator ([gcannon](https://github.com/MDA2AV/gcannon)) fires mixed GET and POST requests with query parsing, Content-Length and chunked body handling. Best of 3 runs is recorded.

<div style="height:20px"></div>

{{< cards >}}
  {{< card title="Realistic Workload" subtitle="Mixed GET/POST requests with query parameters, Content-Length bodies, and chunked Transfer-Encoding." icon="lightning-bolt" >}}
  {{< card title="Fair Comparison" subtitle="Every framework runs on the same hardware with identical load parameters — 512 connections, 12 threads." icon="scale" >}}
  {{< card title="io_uring Load Gen" subtitle="gcannon uses io_uring for zero-copy networking, ensuring the benchmark tool isn't the bottleneck." icon="chip" >}}
{{< /cards >}}
