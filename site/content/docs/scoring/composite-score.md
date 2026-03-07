---
title: Composite Score
---

The composite score combines results from all test profiles into a single number that reflects overall framework performance. It uses a normalized geometric mean that rewards consistency and penalizes weak spots.

## How it works

### Step 1: Average result per profile

For each framework and profile, compute the average RPS across all connection counts. This rewards frameworks that scale well across all concurrency levels rather than just their peak.

### Step 2: Normalize

For each profile, normalize against the best-performing framework:

```
score = (framework_avg_rps / best_avg_rps) * 100
```

This produces a 0-100 value per profile where the top framework scores 100.

### Step 3: Geometric mean

The final composite score is the geometric mean of all per-profile scores:

```
composite = (score_1 * score_2 * ... * score_N) ^ (1/N)
```

The geometric mean ensures that one weak result pulls down the entire composite. A framework that dominates four profiles but performs poorly on one will score significantly lower than a framework that performs well across all of them.

### Effect of the geometric mean

| Scenario (5 profiles) | Arithmetic mean | Geometric mean |
|---|---|---|
| 100, 100, 100, 100, 100 | 100 | 100 |
| 100, 100, 100, 100, 50 | 90 | 87 |
| 100, 100, 100, 100, 20 | 84 | 67 |
| 100, 100, 100, 100, 10 | 82 | 63 |
| 80, 80, 80, 80, 80 | 80 | 80 |
| 100, 100, 100, 20, 20 | 68 | 58 |

One weak result pulls the overall score down significantly compared to an arithmetic mean.

## Profiles included

The composite score includes all available profiles:

| Profile | Workload |
|---|---|
| Baseline | Mixed GET/POST with query parsing (HTTP/1.1) |
| Pipelined | 16 requests batched per connection |
| Short-lived | Connections closed after 10 requests |
| JSON | Dataset processing and serialization |
| Baseline (HTTP/2) | Query parsing over TLS with multiplexed streams |

Frameworks that don't participate in a profile score 0 for that profile. The composite is computed as:

```
composite = geometric_mean(non-zero scores) * (participated / total_profiles)
```

This means missing profiles proportionally reduce the composite score. A framework participating in 4 out of 5 profiles can score at most 80% of what it would score with full participation. This incentivizes frameworks to implement all test endpoints.

## Why this approach

- **Geometric mean** — one bad profile tanks the overall score, rewarding well-rounded frameworks
- **Normalization** — each profile contributes equally regardless of absolute RPS scale (baseline at 1M vs JSON at 200K)
- **Average across connections** — each framework is scored on its average RPS across all connection counts, rewarding consistent scaling rather than just peak performance
