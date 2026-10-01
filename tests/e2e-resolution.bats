#!/usr/bin/env bats

SCRIPT=plugins/bdd-knowledge-base/scripts/sync-kb.sh

setup() {
  WORK="$(mktemp -d)"
  read -r TARBALL SHA ROOT DATA < <(bash tests/helpers/fake-kb.sh "$WORK")
  export KB_FETCH_URL="file://$TARBALL" ROOT DATA WORK
}
teardown() { rm -rf "$WORK"; }

@test "after sync, the KB root resolves under CLAUDE_PLUGIN_DATA/kb" {
  bash "$SCRIPT" "$ROOT" "$DATA" >/dev/null
  # Emulate the skill's resolution order: GHERKIN_KB_PATH -> DATA/kb -> ./.gherkin-kb
  resolved=""
  [ -n "${GHERKIN_KB_PATH:-}" ] && [ -d "${GHERKIN_KB_PATH:-}" ] && resolved="$GHERKIN_KB_PATH"
  [ -z "$resolved" ] && [ -d "$DATA/kb" ] && resolved="$DATA/kb"
  [ "$resolved" = "$DATA/kb" ]
  [ -d "$resolved/docs/gherkin" ]
}

@test "bdd-kb skill documents the same three-step order" {
  f=skills/bdd-kb/SKILL.md
  run grep -q 'GHERKIN_KB_PATH' "$f"; [ "$status" -eq 0 ]
  run grep -q 'CLAUDE_PLUGIN_DATA' "$f"; [ "$status" -eq 0 ]
  run grep -q '.gherkin-kb' "$f"; [ "$status" -eq 0 ]
}

@test "the plugin copy of bdd-kb SKILL.md matches the top-level copy (drift-synced)" {
  run diff -q skills/bdd-kb/SKILL.md plugins/bdd-knowledge-base/skills/bdd-kb/SKILL.md
  [ "$status" -eq 0 ]
}
