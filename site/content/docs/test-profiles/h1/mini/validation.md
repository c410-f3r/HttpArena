---
title: Validation
---

The Mini test uses the same endpoints as the [Mixed Workload](../../mixed/validation). Subscribing to the `mini` test automatically triggers validation for all of them, even if the individual tests are not listed in `meta.json`:

- `/baseline11` — [Baseline validation](../../baseline/validation) (GET, POST, chunked POST, anti-cheat)
- `/json` — [JSON Processing validation](../../json-processing/validation) (structure, totals, Content-Type)
- `/db` — [Database Query validation](../../database/validation) (structure, Content-Type, empty range)
- `/upload` — [Upload validation](../../upload/validation) (byte count, random anti-cheat)
- `/compression` — [Compression validation](../../compression/validation) (Content-Encoding, content, size, per-request)
- `/static/*` — [Static Files validation](../../static/validation) (Content-Types, file sizes, 404)
- `/async-db` — [Async Database validation](../../async-database/validation) (structure, Content-Type, empty range)

The Postgres sidecar is started automatically when `mini` is in the test list, and all required data volumes (`dataset-large.json`, `benchmark.db`, `static/`) are mounted.
