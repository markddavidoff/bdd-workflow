#!/usr/bin/env bats

PIN=plugins/bdd-knowledge-base/kb-version.json

@test "pin is valid JSON with repo/version/asset/sha256" {
  run python3 -c "import json;p=json.load(open('$PIN'));import sys;sys.exit(0 if all(k in p for k in ('repo','version','asset','sha256')) else 1)"
  [ "$status" -eq 0 ]
}

@test "sha256 is filled (not a placeholder)" {
  run grep -q '<sha256' "$PIN"
  [ "$status" -ne 0 ]
}

@test "pin targets the bdd-knowledge-base repo + asset (not the retired gherkin-kb)" {
  run python3 -c "import json;p=json.load(open('$PIN'));import sys;sys.exit(0 if p['repo']=='markddavidoff/bdd-knowledge-base' and p['asset']=='bdd-knowledge-base-1.0.0.tar.gz' else 1)"
  [ "$status" -eq 0 ]
}

@test "/bdd-kb-sync command invokes sync-kb.sh with --force" {
  f=plugins/bdd-knowledge-base/commands/bdd-kb-sync.md
  run grep -q 'sync-kb.sh' "$f"; [ "$status" -eq 0 ]
  run grep -q -- '--force' "$f"; [ "$status" -eq 0 ]
}
