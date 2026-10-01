#!/usr/bin/env bats

load lib/blocklist

@test "corpus-scrub passes on the repo's evals tree (clean or absent)" {
  run bash scripts/check-no-corpus-leak.sh
  [ "$status" -eq 0 ]
}

@test "corpus-scrub fails on a blocklist token" {
  bl_present || skip "no private blocklist available"
  tmp="$(mktemp -d)"; mkdir -p "$tmp/case"
  echo "a $(bl_first_token) fixture" > "$tmp/case/prompt.md"
  run bash scripts/check-no-corpus-leak.sh "$tmp"
  rm -rf "$tmp"
  [ "$status" -ne 0 ]
}

@test "corpus-scrub fails on an issue reference" {
  tmp="$(mktemp -d)"; mkdir -p "$tmp/case"
  echo "see issue #42 for context" > "$tmp/case/prompt.md"
  run bash scripts/check-no-corpus-leak.sh "$tmp"
  rm -rf "$tmp"
  [ "$status" -ne 0 ]
}
