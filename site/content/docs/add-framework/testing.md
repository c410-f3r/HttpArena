---
title: Testing & Submitting
---

## Validate your implementation

Run the validation script to check all endpoints return correct responses:

```bash
./scripts/validate.sh your-framework
```

This builds the Docker image, starts the container, and runs checks for every test profile listed in your `meta.json`. It verifies response bodies, status codes, content types, and anti-cheat randomized inputs.

## Run a benchmark

Test a single profile locally:

```bash
./scripts/benchmark.sh your-framework baseline
```

Run all profiles:

```bash
./scripts/benchmark.sh your-framework
```

By default, results are displayed but not saved. Add `--save` to persist results:

```bash
./scripts/benchmark.sh --save your-framework
```

## Submit a PR

Once validation passes and benchmarks run successfully:

1. Fork [HttpArena](https://github.com/MDA2AV/HttpArena)
2. Add your `frameworks/your-framework/` directory
3. Open a pull request

The PR should include:
- `Dockerfile`
- `meta.json`
- Source files for your server implementation
