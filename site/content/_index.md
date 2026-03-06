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
  {{< card link="docs/running-locally" title="Run Locally" subtitle="Set up and run the full benchmark suite on your own machine with Docker and gcannon." icon="terminal" >}}
  {{< card link="docs/add-framework" title="Add a Framework" subtitle="Add your framework with a Dockerfile and open a PR. Three steps to join the arena." icon="plus-circle" >}}
{{< /cards >}}

