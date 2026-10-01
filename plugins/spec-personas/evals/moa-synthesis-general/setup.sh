#!/usr/bin/env bash
set -euo pipefail
mkdir -p sources
cat > sources/a.md <<'MD'
# Source A (weight: high)
- Latency p99 is the top risk (all agree).
- Ship feature X in v1 — users demand it.
- Timezone handling is missing.
MD
cat > sources/b.md <<'MD'
# Source B (weight: medium)
- Latency p99 is the biggest risk.
- Do NOT ship feature X in v1 — too complex for the timeline.
- Timezone handling is missing.
MD
cat > sources/c.md <<'MD'
# Source C (weight: medium)
- p99 latency is the critical risk.
- Add rate limiting.
MD
