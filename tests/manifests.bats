#!/usr/bin/env bats

load lib/blocklist

@test "four plugin.json manifests are valid JSON with a name" {
  for p in bdd-flow bdd-knowledge-base spec-personas bdd-scaffold; do
    run node -e "const m=require('./plugins/$p/.claude-plugin/plugin.json'); if(!m.name)process.exit(1)"
    [ "$status" -eq 0 ]
  done
}

@test "spec-personas ships 17 curated personas and 4 agents" {
  run bash -c "ls plugins/spec-personas/personas/*.persona | wc -l | tr -d ' '"
  [ "$output" = "17" ]
  run bash -c "ls plugins/spec-personas/agents/*.md | wc -l | tr -d ' '"
  [ "$output" = "4" ]
}

@test "no private recruiting/nonprofit persona shipped (CR3)" {
  # Enumeration of the withheld taxonomy lives only in the private, gitignored blocklist —
  # this test does not name it. Fail if any shipped persona filename matches that pattern.
  WF=scripts/.withheld-personas-blocklist
  [ -f "$WF" ] || skip "no private withheld blocklist available"
  pat="$(tr -d '\n' < "$WF")"
  run bash -c "ls plugins/spec-personas/personas/ 2>/dev/null | grep -Eiq \"$pat\""
  [ "$status" -ne 0 ]
}

@test "bdd-flow ships 4 adversarial agents" {
  run bash -c "ls plugins/bdd-flow/agents/*.md | wc -l | tr -d ' '"
  [ "$output" = "4" ]
}

@test "plugin agents carry no proprietary domain vocab (CR1)" {
  bl_present || skip "no private blocklist available"
  run grep -rEl "$(bl_pattern)" plugins/*/agents
  [ "$status" -ne 0 ]
}
