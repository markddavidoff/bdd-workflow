#!/usr/bin/env bats

@test "bdd-kb SKILL.md contains no absolute or ~ paths" {
  run grep -nE '(/Users/|/home/|~/work/)' skills/bdd-kb/SKILL.md
  [ "$status" -ne 0 ]   # grep finds nothing -> non-zero exit
}

@test "bdd-kb SKILL.md documents the resolution order" {
  run grep -q 'GHERKIN_KB_PATH' skills/bdd-kb/SKILL.md
  [ "$status" -eq 0 ]
  run grep -q 'CLAUDE_PLUGIN_DATA' skills/bdd-kb/SKILL.md
  [ "$status" -eq 0 ]
}
