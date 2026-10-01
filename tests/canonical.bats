#!/usr/bin/env bats

load lib/blocklist

@test "four canonical skills exist with a matching frontmatter name" {
  for s in bdd-feature-sync e2e-test-generation spec-review persona-manager; do
    [ -f "skills/$s/SKILL.md" ]
    run grep -qE "^name: $s" "skills/$s/SKILL.md"
    [ "$status" -eq 0 ]
  done
}

@test "no personas or agents leaked into canonical skills" {
  run bash -c "find skills -type d \( -name agents -o -name personas \) | wc -l | tr -d ' '"
  [ "$output" = "0" ]
}

@test "migrated skills carry no proprietary domain vocab (CR1)" {
  bl_present || skip "no private blocklist available"
  run grep -rEl "$(bl_pattern)" skills/
  [ "$status" -ne 0 ]
}
