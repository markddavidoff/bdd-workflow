#!/usr/bin/env bats

AGENT=plugins/spec-personas/agents/moa-synthesizer.md

@test "moa-synthesizer agent frontmatter is valid and generic" {
  run python3 -c "
import sys,re
t=open('$AGENT').read()
m=re.match(r'^---\n(.*?)\n---', t, re.S)
sys.exit(0 if m and 'name: moa-synthesizer' in m.group(1) else 1)
"
  [ "$status" -eq 0 ]
}

@test "moa-synthesizer agent is free of persona-specific vocabulary" {
  # The generic engine must not bake persona/interview/product-owner output.
  run grep -niE 'persona|product owner|interview question|Review Panel' "$AGENT"
  [ "$status" -ne 0 ]
}

@test "moa-synthesizer agent states the generic MoA principles" {
  grep -qiE 'consensus' "$AGENT"
  grep -qiE 'disagreement|divergen' "$AGENT"
  grep -qiE 'weight' "$AGENT"
  grep -qiE 'dedup' "$AGENT"
}

PSKILL=plugins/spec-personas/skills/persona-moa-synthesis/SKILL.md

@test "persona-moa-synthesis skill exists with valid frontmatter" {
  [ -f "$PSKILL" ]
  run python3 -c "
import sys,re
t=open('$PSKILL').read()
m=re.match(r'^---\n(.*?)\n---', t, re.S)
sys.exit(0 if m and 'name: persona-moa-synthesis' in m.group(1) and 'description:' in m.group(1) else 1)
"
  [ "$status" -eq 0 ]
}

@test "persona-moa-synthesis carries the persona output contract and dispatches the agent" {
  grep -qiE 'moa-synthesizer' "$PSKILL"
  grep -qiE 'weight' "$PSKILL"
  # All 7 persona output sections that left the agent must be present (guards the seam —
  # a future edit dropping any one must turn this red, not stay green on a token subset).
  grep -qi 'Review Panel' "$PSKILL"
  grep -qi 'Critical Gaps' "$PSKILL"
  grep -qiE 'High-Priority' "$PSKILL"
  grep -qiE 'Nice-to-Have' "$PSKILL"
  grep -qi 'Conflicts & Decision Points' "$PSKILL"
  grep -qi 'Interview Questions' "$PSKILL"
  grep -qi 'Improvement Recommendations' "$PSKILL"
}

@test "persona-moa-synthesis is registered in the sync MAP" {
  grep -qE 'spec-personas:.*persona-moa-synthesis' scripts/sync-skills.sh
}

@test "persona-moa-synthesis has no absolute paths" {
  run grep -nE '(/Users/|/home/)' "$PSKILL"
  [ "$status" -ne 0 ]
}

SREVIEW=plugins/spec-personas/skills/spec-review/SKILL.md

@test "spec-review Phase 3 routes synthesis through persona-moa-synthesis" {
  grep -qi 'persona-moa-synthesis' "$SREVIEW"
}

GSKILL=plugins/spec-personas/skills/moa-synthesis/SKILL.md

@test "moa-synthesis general skill exists with valid frontmatter" {
  [ -f "$GSKILL" ]
  run python3 -c "
import sys,re
t=open('$GSKILL').read()
m=re.match(r'^---\n(.*?)\n---', t, re.S)
sys.exit(0 if m and 'name: moa-synthesis' in m.group(1) and 'description:' in m.group(1) else 1)
"
  [ "$status" -eq 0 ]
}

@test "moa-synthesis general skill is registered in the sync MAP" {
  # ,moa-synthesis(,|") matches the standalone entry, NOT the persona-moa-synthesis substring
  grep -qE ',moa-synthesis(,|")' scripts/sync-skills.sh
}

@test "moa-synthesis general skill stays plugin-neutral (standalone guard surface)" {
  run grep -niE 'bdd-flow|bdd-feature-sync|bdd-kb|GHERKIN_KB' "$GSKILL"
  [ "$status" -ne 0 ]
}
