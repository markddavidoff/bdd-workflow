#!/usr/bin/env bash
# Fail-soft: never exit non-zero from the SessionStart path; never block the session.
#
# Prints a one-line invite to /bdd-tutorial as SessionStart context, but only on a real
# interactive startup. Gating uses DOCUMENTED SessionStart signals (no reliable TTY/mode env
# var exists): the stdin JSON's `source` must be "startup", there must be no `agent_type`
# (that marks a subagent), and CI / an explicit opt-out suppress it. A first run always
# consumes the marker so a later session is not nagged with stale framing.
set -uo pipefail
DATA="${1:-}"

# Read the SessionStart JSON from stdin (never block on an unread pipe).
input="$(cat 2>/dev/null || true)"

# Fail-soft: with no data dir we cannot gate on the marker, so do nothing rather than error.
[ -n "$DATA" ] || exit 0
MARKER="$DATA/.tutorial-invited"

# First run consumes the invite regardless of context: write the marker up front.
if [ -f "$MARKER" ]; then exit 0; fi
mkdir -p "$DATA" 2>/dev/null || true
printf '{"invited_at":"%s"}\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$MARKER" 2>/dev/null || true

# Explicit suppressors (deterministic).
if [ -n "${CI:-}" ] || [ -n "${CLAUDE_TUTORIAL_NONINTERACTIVE:-}" ]; then exit 0; fi

# Parse `source` and `agent_type` from the JSON. On any parse failure, both stay empty and the
# invite is suppressed (fail-safe: never inject on unknown input).
fields="$(printf '%s' "$input" | python3 -c '
import sys, json
try:
    d = json.load(sys.stdin)
    print((d.get("source") or "") + "\t" + (d.get("agent_type") or ""))
except Exception:
    print("\t")
' 2>/dev/null || printf '\t')"
source_val="${fields%%$'\t'*}"
agent_val="${fields#*$'\t'}"

# Emit only on a real interactive startup that is not a subagent.
if [ "$source_val" = "startup" ] && [ -z "$agent_val" ]; then
  echo "👋 New to bdd-knowledge-base? Run /bdd-tutorial for a 5-min guided walkthrough."
fi
exit 0
