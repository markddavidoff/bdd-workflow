#!/usr/bin/env bats

@test "SECURITY.md exists (the plugins run curl/rm on user machines; LICENSE + README reference it)" {
  [ -f SECURITY.md ]
}

@test "SECURITY.md documents a disclosure path" {
  run grep -qiE 'report|disclos|security' SECURITY.md
  [ "$status" -eq 0 ]
}
