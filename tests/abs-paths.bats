#!/usr/bin/env bats

setup() { make sync >/dev/null; }

@test "shipped content has no absolute paths" {
  run bash scripts/check-no-abs-paths.sh
  [ "$status" -eq 0 ]
}

@test "abs-path guard fires on a planted path (no false green)" {
  echo "/Users/someone/secret" > skills/.abs-probe.tmp
  run bash scripts/check-no-abs-paths.sh
  rm -f skills/.abs-probe.tmp
  [ "$status" -eq 1 ]
}
