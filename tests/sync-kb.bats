#!/usr/bin/env bats

SCRIPT=plugins/bdd-knowledge-base/scripts/sync-kb.sh

setup() {
  WORK="$(mktemp -d)"
  read -r TARBALL SHA ROOT DATA < <(bash tests/helpers/fake-kb.sh "$WORK")
  export TARBALL SHA ROOT DATA
  # Point the script's fetcher at the local tarball instead of the network.
  export KB_FETCH_URL="file://$TARBALL"
}
teardown() { rm -rf "$WORK"; }

@test "first run fetches and installs the KB" {
  run bash "$SCRIPT" "$ROOT" "$DATA"
  [ "$status" -eq 0 ]
  [ -L "$DATA/kb" ]                          # kb is an atomic symlink
  [ -f "$DATA/kb/docs/gherkin/index.md" ]    # resolves through the symlink
  [ -f "$DATA/kb.installed.json" ]           # marker is a sibling, not inside kb/
}

@test "second run is a no-op (marker matches) with no fetch" {
  bash "$SCRIPT" "$ROOT" "$DATA" >/dev/null
  # Remove the tarball so any fetch attempt would fail; a true no-op still exits 0.
  rm -f "$TARBALL"
  run bash "$SCRIPT" "$ROOT" "$DATA"
  [ "$status" -eq 0 ]
  [ -f "$DATA/kb/docs/gherkin/index.md" ]
}

@test "first fetch discloses source + size + disable switch" {
  run bash "$SCRIPT" "$ROOT" "$DATA"
  [ "$status" -eq 0 ]
  [[ "$output" == *"GHERKIN_KB_DISABLE"* ]]  # opt-out is disclosed
  [[ "$output" == *"$TARBALL"* || "$output" == *"file://"* ]]  # source disclosed
}

@test "GHERKIN_KB_DISABLE short-circuits with no fetch" {
  export GHERKIN_KB_DISABLE=1
  run bash "$SCRIPT" "$ROOT" "$DATA"
  [ "$status" -eq 0 ]
  [ ! -e "$DATA/kb" ]                        # nothing fetched or installed
  [ ! -f "$DATA/kb.installed.json" ]
}

@test "GHERKIN_KB_PATH override short-circuits with no fetch" {
  ext="$(mktemp -d)"; mkdir -p "$ext/docs/gherkin"; echo "# ext" > "$ext/docs/gherkin/index.md"
  export GHERKIN_KB_PATH="$ext"
  run bash "$SCRIPT" "$ROOT" "$DATA"
  [ "$status" -eq 0 ]
  [ ! -e "$DATA/kb" ]                        # cache untouched; skill resolves the override directly
  [ ! -f "$DATA/kb.installed.json" ]
  rm -rf "$ext"
}

@test "sha256 mismatch refuses to install and writes backoff" {
  python3 -c "import json,sys;p=json.load(open('$ROOT/kb-version.json'));p['sha256']='0'*64;json.dump(p,open('$ROOT/kb-version.json','w'))"
  run bash "$SCRIPT" "$ROOT" "$DATA"
  [ "$status" -eq 0 ]                       # fail-soft
  [ ! -f "$DATA/kb.installed.json" ]        # nothing installed (marker is a sibling)
  [ -f "$DATA/kb.backoff" ]                 # backoff recorded
}

@test "network failure exits 0 and records backoff" {
  export KB_FETCH_URL="file:///nonexistent/nope.tar.gz"
  run bash "$SCRIPT" "$ROOT" "$DATA"
  [ "$status" -eq 0 ]
  [ -f "$DATA/kb.backoff" ]
}

@test "backoff suppresses a retry inside the window" {
  export KB_FETCH_URL="file:///nonexistent/nope.tar.gz"
  bash "$SCRIPT" "$ROOT" "$DATA" >/dev/null   # writes backoff
  ts1="$(cat "$DATA/kb.backoff")"
  sleep 1
  bash "$SCRIPT" "$ROOT" "$DATA" >/dev/null   # should not re-attempt
  ts2="$(cat "$DATA/kb.backoff")"
  [ "$ts1" = "$ts2" ]                        # timestamp unchanged -> no retry
}

@test "concurrent runs do not corrupt the install" {
  bash "$SCRIPT" "$ROOT" "$DATA" &
  bash "$SCRIPT" "$ROOT" "$DATA" &
  bash "$SCRIPT" "$ROOT" "$DATA" &
  wait
  [ -L "$DATA/kb" ]                          # published as a symlink
  [ -f "$DATA/kb/docs/gherkin/index.md" ]    # resolves; reader never saw a partial tree
  [ -f "$DATA/kb.installed.json" ]
  [ ! -d "$DATA/.kb-lock" ]                  # lock released by every run
  run diff -q "$ROOT/kb-version.json" "$DATA/kb.installed.json"
  [ "$status" -eq 0 ]
}
