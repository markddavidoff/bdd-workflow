#!/usr/bin/env bats

HOOKS=plugins/bdd-knowledge-base/hooks/hooks.json
KB_PLUGIN=plugins/bdd-knowledge-base/.claude-plugin/plugin.json
FLOW_PLUGIN=plugins/bdd-flow/.claude-plugin/plugin.json

@test "SessionStart hook invokes sync-kb with both plugin env vars" {
  run python3 -c "import json;h=json.load(open('$HOOKS'));c=h['hooks']['SessionStart'][0]['hooks'][0]['command'];import sys;sys.exit(0 if 'sync-kb.sh' in c and 'CLAUDE_PLUGIN_ROOT' in c and 'CLAUDE_PLUGIN_DATA' in c else 1)"
  [ "$status" -eq 0 ]
}

@test "the standard hooks/hooks.json files exist (auto-loaded)" {
  [ -f "$HOOKS" ]
  [ -f plugins/bdd-flow/hooks/hooks.json ]
}

# Regression guard: the standard hooks/hooks.json is loaded automatically, so a manifest that ALSO
# declares "hooks": "./hooks/hooks.json" causes a duplicate-load failure at install time (which
# `claude plugin validate` does NOT catch). Neither manifest may declare it.
@test "no plugin manifest re-declares the standard hooks file" {
  for m in "$KB_PLUGIN" "$FLOW_PLUGIN"; do
    run python3 -c "import json;m=json.load(open('$m'));import sys;sys.exit(1 if m.get('hooks')=='./hooks/hooks.json' else 0)"
    [ "$status" -eq 0 ]
  done
}
