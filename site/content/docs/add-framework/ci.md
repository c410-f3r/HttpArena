---
title: CI & Runner
---

## GitHub Actions

HttpArena uses four GitHub Actions workflows to automate validation, benchmarking, and deployment.

### Validate Framework

**Trigger:** Automatically on every PR that modifies files under `frameworks/` or `scripts/validate.sh`.

Detects which frameworks were changed in the PR and runs `./scripts/validate.sh` against each one. If validation fails, the PR check fails — you must fix the issues before merging.

### Benchmark

**Trigger:** Automatically when a push to `main` modifies files under `frameworks/`, or manually via workflow dispatch.

When triggered automatically, it detects which frameworks changed in the latest commit and benchmarks only those. When triggered manually, you can specify:
- **Framework** — a specific framework name, or leave empty to benchmark all changed frameworks
- **Profile** — a specific test profile (e.g. `baseline`, `baseline-h2`), or leave empty to run all profiles

Results are committed and pushed to `main` automatically by the HttpArena Bot.

### Benchmark PR

**Trigger:** Manual only (workflow dispatch). Requires a PR number and framework name.

Checks out the PR branch, runs the benchmark, and posts the results as a comment on the PR. This lets maintainers benchmark a new framework submission before merging, so contributors can see how their implementation performs on the hosted runner. An optional profile parameter lets you run a specific test instead of the full suite.

### Deploy Site

**Trigger:** Automatically when a push to `main` modifies files under `site/`, or manually via workflow dispatch.

Builds the Hugo site and deploys it to GitHub Pages. This runs on GitHub-hosted Ubuntu runners (not the self-hosted runner).

## Hosted runner

The Validate, Benchmark, and Benchmark PR workflows run on a **self-hosted runner** — a dedicated bare-metal machine configured for reproducible, low-noise benchmarking. This ensures all frameworks are tested on identical hardware under controlled conditions, with CPU governors locked, background services minimized, and no resource contention from other CI jobs.

Only the Deploy Site workflow uses GitHub-hosted runners, since it only builds static HTML and doesn't need controlled hardware.
