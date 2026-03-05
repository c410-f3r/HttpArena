---
title: HttpArena
toc: false
---

# Leaderboard

HTTP framework benchmark results. Sorted by requests per second (best of 3 x 30s runs).

**Test:** `GET/POST /bench` with query parameter parsing, Content-Length and chunked body handling.
512 connections, 12 threads, 100 requests per connection, pipeline depth 1.

{{< leaderboard >}}

---

Want to participate? Submit a PR with your framework in the `frameworks/` directory. See the [GitHub repo](https://github.com/MDA2AV/HttpArena) for details.
