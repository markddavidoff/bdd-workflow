#!/usr/bin/env bats

SKILL=plugins/bdd-knowledge-base/skills/bdd-tutorial/SKILL.md

@test "bdd-tutorial skill file exists" {
  [ -f "$SKILL" ]
}

@test "bdd-tutorial skill has name and description frontmatter" {
  run python3 -c "
import sys,re
t=open('$SKILL').read()
m=re.match(r'^---\n(.*?)\n---', t, re.S)
sys.exit(0 if m and 'name: bdd-tutorial' in m.group(1) and 'description:' in m.group(1) else 1)
"
  [ "$status" -eq 0 ]
}

@test "bdd-tutorial skill contains no absolute paths" {
  run grep -nE '(/Users/|/home/)' "$SKILL"
  [ "$status" -ne 0 ]
}

@test "bdd-tutorial skill names its delegation targets" {
  grep -q 'persona-manager' "$SKILL"
  grep -q 'bdd-feature-sync' "$SKILL"
}

CMD=plugins/bdd-knowledge-base/commands/bdd-tutorial.md

@test "bdd-tutorial command file exists with a description" {
  [ -f "$CMD" ]
  run python3 -c "
import sys,re
t=open('$CMD').read()
m=re.match(r'^---\n(.*?)\n---', t, re.S)
sys.exit(0 if m and 'description:' in m.group(1) else 1)
"
  [ "$status" -eq 0 ]
}

@test "bdd-tutorial command invokes the bdd-tutorial skill" {
  grep -q 'bdd-tutorial' "$CMD"
}

INVITE=plugins/bdd-knowledge-base/scripts/tutorial-invite.sh
HOOKS=plugins/bdd-knowledge-base/hooks/hooks.json

@test "invite script exists and is executable" {
  [ -x "$INVITE" ]
}

@test "interactive startup prints the invite and writes the marker" {
  data="$(mktemp -d)"
  run bash -c "echo '{\"source\":\"startup\"}' | env -u CI -u CLAUDE_TUTORIAL_NONINTERACTIVE bash '$INVITE' '$data'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"/bdd-tutorial"* ]]
  [ -f "$data/.tutorial-invited" ]
  rm -rf "$data"
}

@test "second startup is silent (marker honored)" {
  data="$(mktemp -d)"
  echo '{"source":"startup"}' | bash "$INVITE" "$data" >/dev/null
  run bash -c "echo '{\"source\":\"startup\"}' | bash '$INVITE' '$data'"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
  rm -rf "$data"
}

@test "non-startup source (resume) is silent BUT writes the marker" {
  data="$(mktemp -d)"
  run bash -c "echo '{\"source\":\"resume\"}' | bash '$INVITE' '$data'"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
  [ -f "$data/.tutorial-invited" ]
  rm -rf "$data"
}

@test "subagent context (agent_type present) is silent BUT writes the marker" {
  data="$(mktemp -d)"
  run bash -c "echo '{\"source\":\"startup\",\"agent_type\":\"explore\"}' | bash '$INVITE' '$data'"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
  [ -f "$data/.tutorial-invited" ]
  rm -rf "$data"
}

@test "CI env suppresses the invite but writes the marker" {
  data="$(mktemp -d)"
  run bash -c "echo '{\"source\":\"startup\"}' | env CI=1 bash '$INVITE' '$data'"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
  [ -f "$data/.tutorial-invited" ]
  rm -rf "$data"
}

@test "explicit opt-out suppresses the invite but writes the marker" {
  data="$(mktemp -d)"
  run bash -c "echo '{\"source\":\"startup\"}' | env CLAUDE_TUTORIAL_NONINTERACTIVE=1 bash '$INVITE' '$data'"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
  [ -f "$data/.tutorial-invited" ]
  rm -rf "$data"
}

@test "unparseable stdin is silent BUT writes the marker (fail-safe)" {
  data="$(mktemp -d)"
  run bash -c "echo 'not json' | bash '$INVITE' '$data'"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
  [ -f "$data/.tutorial-invited" ]
  rm -rf "$data"
}

@test "empty data arg is fail-soft (exit 0, silent) not an error" {
  run bash -c "echo '{\"source\":\"startup\"}' | bash '$INVITE' ''"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "hooks.json declares two SessionStart hooks (sync-kb + tutorial-invite)" {
  run python3 -c "
import json,sys
h=json.load(open('$HOOKS'))
cmds=[x['command'] for grp in h['hooks']['SessionStart'] for x in grp['hooks']]
joined=' '.join(cmds)
sys.exit(0 if 'sync-kb.sh' in joined and 'tutorial-invite.sh' in joined else 1)
"
  [ "$status" -eq 0 ]
}
