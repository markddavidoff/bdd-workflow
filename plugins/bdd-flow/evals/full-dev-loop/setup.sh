#!/usr/bin/env bash
mkdir -p docs/features tests src
printf '{"version":1,"featureFilesDir":"docs/features","e2eDir":"tests"}' > .bdd.json
cat > package.json <<'JSON'
{ "name": "toy", "version": "1.0.0", "scripts": { "test": "node --test" } }
JSON
