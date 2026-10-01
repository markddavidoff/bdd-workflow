#!/usr/bin/env bash
# Plain repo: no .bdd.json, no CLAUDE.md. A decoy .feature under node_modules must NOT count (H12).
mkdir -p src node_modules/somepkg
echo "// plain repo, no BDD" > src/util.js
echo "Feature: vendored decoy" > node_modules/somepkg/foo.feature
