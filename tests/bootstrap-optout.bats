#!/usr/bin/env bats

SKILL=skills/bdd-kb/SKILL.md
CLEAN=plugins/bdd-knowledge-base/commands/bdd-kb-clean.md

@test "bdd-kb skill documents a manual (non-Claude) bootstrap" {
  run grep -qi 'Manual (non-Claude) bootstrap' "$SKILL"; [ "$status" -eq 0 ]
  run grep -q 'shasum -a 256 -c' "$SKILL"; [ "$status" -eq 0 ]   # verify step present
  run grep -q '.gherkin-kb' "$SKILL"; [ "$status" -eq 0 ]
}

@test "bdd-kb skill documents opt-out controls" {
  run grep -q 'GHERKIN_KB_DISABLE' "$SKILL"; [ "$status" -eq 0 ]
  run grep -q '/bdd-kb-clean' "$SKILL"; [ "$status" -eq 0 ]
}

@test "/bdd-kb-clean command removes the plugin KB cache" {
  run grep -q 'CLAUDE_PLUGIN_DATA' "$CLEAN"; [ "$status" -eq 0 ]
  run grep -q 'rm -rf' "$CLEAN"; [ "$status" -eq 0 ]
  run grep -q 'kb.installed.json' "$CLEAN"; [ "$status" -eq 0 ]
}
