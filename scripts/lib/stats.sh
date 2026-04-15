# scripts/lib/stats.sh — docker CPU/memory sampling during a run.
#
# Uses `docker stats --no-stream` in a background polling loop. An earlier
# version tried to stream `docker stats` with `--no-stream` omitted for
# efficiency, but docker's CLI buffers pipe output and the log never
# flushes before we kill it — resulting in zero samples and CPU=0%.
# The polling approach is slightly less efficient (one docker CLI spawn
# per sample, ~2 Hz) but reliably produces clean line-oriented output.
#
# Usage:
#   stats_start <container...>    # starts background collector
#   stats_stop                    # stops, fills STATS_AVG_CPU / STATS_PEAK_MEM

STATS_PID=""
STATS_LOG=""
STATS_AVG_CPU="0%"
STATS_PEAK_MEM="0MiB"

# Start a background poller. Accepts one or more container names. For
# multi-container (gateway) runs, each sample sums CPU and memory across
# all containers to produce a per-stack total.
stats_start() {
    STATS_LOG=$(mktemp)
    local containers=("$@")
    (
        while true; do
            if [ "${#containers[@]}" -gt 1 ]; then
                # Gateway / multi-container: sum across all samples in one snapshot.
                docker stats --no-stream --format '{{.CPUPerc}} {{.MemUsage}}' "${containers[@]}" 2>/dev/null \
                    | awk '{
                        gsub(/%/, "", $1); cpu += $1
                        split($2, a, "/"); v = a[1]; gsub(/[^0-9.]/, "", v)
                        if ($2 ~ /GiB/) v = v * 1024
                        mem += v + 0
                    } END {
                        if (NR > 0) printf "%.1f%% %.1fMiB\n", cpu, mem
                    }'
            else
                docker stats --no-stream --format '{{.CPUPerc}} {{.MemUsage}}' "${containers[0]}" 2>/dev/null
            fi
        done
    ) >"$STATS_LOG" 2>/dev/null &
    STATS_PID=$!
}

stats_stop() {
    [ -n "$STATS_PID" ] && kill "$STATS_PID" 2>/dev/null
    wait "$STATS_PID" 2>/dev/null || true

    if [ -f "$STATS_LOG" ]; then
        STATS_AVG_CPU=$(awk '
            {
                gsub(/%/, "", $1)
                if ($1 + 0 > 0) { sum += $1; n++ }
            }
            END { if (n > 0) printf "%.1f%%", sum / n; else print "0%" }
        ' "$STATS_LOG")

        STATS_PEAK_MEM=$(awk '
            {
                split($2, a, "/"); v = a[1]
                gsub(/[^0-9.]/, "", v)
                unit = $2
                gsub(/[0-9.]/, "", unit)
                if (v + 0 > max) { max = v + 0; u = unit }
            }
            END { if (max > 0) printf "%.1f%s", max, u; else print "0MiB" }
        ' "$STATS_LOG")

        rm -f "$STATS_LOG"
    fi

    STATS_PID=""
    STATS_LOG=""
}
