#!/usr/bin/env bats

setup() { make sync >/dev/null; }

WF=scripts/.withheld-personas-blocklist

@test "no withheld recruiting/nonprofit persona taxonomy in shipped content (CR3)" {
  run bash scripts/check-no-withheld-personas.sh
  [ "$status" -eq 0 ]
}

@test "CR3 guard fires on a planted withheld token (no false green)" {
  [ -f "$WF" ] || skip "no private withheld blocklist available"
  tok="$(tr -d '\n' < "$WF" | cut -d'|' -f1)"
  echo "$tok" > skills/.cr3-probe.tmp
  run bash scripts/check-no-withheld-personas.sh
  rm -f skills/.cr3-probe.tmp
  [ "$status" -eq 1 ]
}
