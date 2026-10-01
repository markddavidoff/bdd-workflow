#!/usr/bin/env bash
# Fail-soft: never exit non-zero from the SessionStart path.
set -uo pipefail
ROOT="${1:?}"; DATA="${2:?}"; FORCE="${3:-}"
PIN="$ROOT/kb-version.json"
KBDIR="$DATA/kb"                  # published as a symlink -> versions/<sha> (atomic swap; POC 7)
VERSIONS="$DATA/versions"
MARKER="$DATA/kb.installed.json"  # sibling of the symlink, not inside the swapped tree
BACKOFF="$DATA/kb.backoff"
LOCKDIR="$DATA/.kb-lock"          # mkdir-lock (atomic, portable; macOS lacks flock)
BACKOFF_SECS=1800

log() { echo "[sync-kb] $*" >&2; }
sha_of() { shasum -a 256 "$1" 2>/dev/null | awk '{print $1}' || sha256sum "$1" | awk '{print $1}'; }

# H2 opt-out / override — these win unconditionally (even under --force): the KB auto-fetch is
# strictly opt-outable, and an explicit KB path means "use mine, do not fetch".
if [ -n "${GHERKIN_KB_DISABLE:-}" ]; then
  log "GHERKIN_KB_DISABLE set; KB auto-fetch disabled (no network)"; exit 0
fi
if [ -n "${GHERKIN_KB_PATH:-}" ] && [ -d "${GHERKIN_KB_PATH:-}" ]; then
  log "GHERKIN_KB_PATH=$GHERKIN_KB_PATH in use; skipping fetch (skill resolves it directly)"; exit 0
fi

# Steady state: marker matches pin -> nothing to do.
if [ -z "$FORCE" ] && [ -f "$MARKER" ] && diff -q "$PIN" "$MARKER" >/dev/null 2>&1; then
  exit 0
fi

mkdir -p "$DATA" "$VERSIONS"
# Serialize concurrent sessions with a portable mkdir-lock (atomic create; no flock — macOS lacks
# it). Bounded wait (~10s), then defer to whoever holds it; reclaim a stale lock whose holder is
# gone. (POC 7: proven on macOS across 40 iterations, 3 concurrent installers.)
acquire_lock() {
  local waited=0
  while ! mkdir "$LOCKDIR" 2>/dev/null; do
    if [ -f "$LOCKDIR/pid" ] && ! kill -0 "$(cat "$LOCKDIR/pid" 2>/dev/null)" 2>/dev/null; then
      rm -rf "$LOCKDIR" 2>/dev/null || true; continue   # stale holder -> reclaim
    fi
    sleep 0.05; waited=$((waited+1))
    [ "$waited" -gt 200 ] && return 1
  done
  echo "$$" > "$LOCKDIR/pid"
}
if ! acquire_lock; then log "another session holds the lock; skipping"; exit 0; fi
tmp=""
trap 'rm -rf "$LOCKDIR" 2>/dev/null || true; [ -n "${tmp:-}" ] && rm -rf "$tmp"' EXIT

# Re-check after acquiring the lock (another session may have just finished).
if [ -z "$FORCE" ] && [ -f "$MARKER" ] && diff -q "$PIN" "$MARKER" >/dev/null 2>&1; then
  exit 0
fi

# Backoff: don't retry a failed fetch more than once per BACKOFF_SECS.
if [ -z "$FORCE" ] && [ -f "$BACKOFF" ]; then
  last="$(cat "$BACKOFF" 2>/dev/null || echo 0)"
  now="$(date +%s)"
  if [ $(( now - last )) -lt "$BACKOFF_SECS" ]; then
    log "in backoff window; not retrying"; exit 0
  fi
fi

asset="$(python3 -c "import json;print(json.load(open('$PIN'))['asset'])" 2>/dev/null)"
want_sha="$(python3 -c "import json;print(json.load(open('$PIN'))['sha256'])" 2>/dev/null)"
repo="$(python3 -c "import json;print(json.load(open('$PIN'))['repo'])" 2>/dev/null)"
ver="$(python3 -c "import json;print(json.load(open('$PIN'))['version'])" 2>/dev/null)"
url="${KB_FETCH_URL:-https://github.com/$repo/releases/download/v$ver/$asset}"

# H2 disclosure: tell the user, once, before the network call, what is being fetched and how to
# opt out of future auto-fetches.
log "fetching BDD KB $ver from $url — disable future auto-fetch with GHERKIN_KB_DISABLE=1"

tmp="$(mktemp -d "$DATA/.kb-tmp.XXXXXX")"   # same fs as $DATA -> the publish rename is atomic
if ! curl -fsSL --max-time 60 "$url" -o "$tmp/kb.tar.gz"; then
  log "fetch failed (run /bdd-kb-sync to retry); KB unavailable for now"; date +%s > "$BACKOFF"; exit 0
fi

size="$(wc -c < "$tmp/kb.tar.gz" | tr -d ' ')"
log "downloaded $asset ($size bytes)"

got_sha="$(sha_of "$tmp/kb.tar.gz")"
if [ "$got_sha" != "$want_sha" ]; then
  log "sha256 mismatch: want $want_sha got $got_sha (refusing to install)"; date +%s > "$BACKOFF"; exit 0
fi

# Extract into the private same-fs temp dir, then publish atomically.
mkdir -p "$tmp/out"
if ! tar -xzf "$tmp/kb.tar.gz" -C "$tmp/out"; then
  log "extract failed"; date +%s > "$BACKOFF"; exit 0
fi
# Content-addressed versioned dir (idempotent: an identical payload lands the same dir).
verdir="$VERSIONS/$want_sha"
rm -rf "$verdir" 2>/dev/null || true
mv "$tmp/out" "$verdir"                       # rename: atomic on the same fs
# Atomic symlink swap: point kb -> versions/<sha>. NOT `mv` — on macOS and on GNU without the
# non-portable `-T`, `mv` FOLLOWS a symlink-to-dir target and moves INTO it instead of replacing
# it (the H11 trap; the update silently no-ops). perl's rename() is rename(2): atomic, does not
# follow the destination symlink, and ships on macOS + Linux. (POC 7 found this empirically.)
linktmp="$(mktemp -u "$DATA/.kb-link.XXXXXX")"
ln -s "versions/$want_sha" "$linktmp"
if ! perl -e 'rename($ARGV[0],$ARGV[1]) or die "rename: $!"' "$linktmp" "$KBDIR" 2>/dev/null; then
  log "symlink swap failed"; rm -f "$linktmp"; date +%s > "$BACKOFF"; exit 0
fi
# Marker written ONLY after a successful publish (no false-success on a faulted run).
cp "$PIN" "$MARKER"; rm -f "$BACKOFF"
log "installed KB $ver (versions/$want_sha)"
exit 0
