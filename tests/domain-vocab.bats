#!/usr/bin/env bats

load lib/blocklist

setup() { make sync >/dev/null; }

@test "shipped content has no proprietary domain vocab" {
  run bash scripts/check-no-domain-vocab.sh
  [ "$status" -eq 0 ]
}

@test "domain-vocab guard fires on a planted token (no false green)" {
  bl_present || skip "no private blocklist available"
  echo "$(bl_first_token)" > skills/.vocab-probe.tmp
  run bash scripts/check-no-domain-vocab.sh
  rm -f skills/.vocab-probe.tmp
  [ "$status" -eq 1 ]
}
