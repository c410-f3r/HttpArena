---
title: Load Generators
toc: false
---

HttpArena uses two load generators: **gcannon** for HTTP/1.1 profiles and **h2load** for HTTP/2.

{{< cards >}}
  {{< card link="gcannon" title="gcannon" subtitle="Custom io_uring-based HTTP/1.1 load generator built for maximum throughput." icon="lightning-bolt" >}}
  {{< card link="h2load" title="h2load" subtitle="HTTP/2 load generator from nghttp2 with TLS and stream multiplexing support." icon="globe-alt" >}}
{{< /cards >}}
