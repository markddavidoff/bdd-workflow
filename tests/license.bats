#!/usr/bin/env bats

@test "LICENSE and NOTICE files exist at repo root" {
  [ -f LICENSE ]
  [ -f NOTICE ]
}

@test "LICENSE is source-available: prohibits derivative works" {
  run grep -qi 'derivative' LICENSE
  [ "$status" -eq 0 ]
}

@test "LICENSE disclaims warranty" {
  run grep -qi 'warranty' LICENSE
  [ "$status" -eq 0 ]
}
