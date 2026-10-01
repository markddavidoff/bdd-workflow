#!/usr/bin/env bats

@test "marketplace.json is valid JSON with four plugins" {
  run node -e "const m=require('./.claude-plugin/marketplace.json'); if(m.plugins.length!==4)process.exit(1)"
  [ "$status" -eq 0 ]
}

@test "each plugin source directory is declared" {
  for p in bdd-flow bdd-knowledge-base spec-personas bdd-scaffold; do
    run node -e "const m=require('./.claude-plugin/marketplace.json'); if(!m.plugins.find(x=>x.name==='$p'))process.exit(1)"
    [ "$status" -eq 0 ]
  done
}

@test "bdd-kb ships in bdd-knowledge-base, not bdd-flow" {
  [ -d plugins/bdd-knowledge-base/skills/bdd-kb ]
  [ ! -d plugins/bdd-flow/skills/bdd-kb ]
}
