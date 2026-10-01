#!/usr/bin/env bash
# usage: fake-kb.sh <workdir>  -> prints "TARBALL SHA PINPATH DATADIR"
# Builds a tiny tarball mimicking a KB release + a matching pin, so tests never hit the network.
set -euo pipefail
work="$1"; mkdir -p "$work/src/docs/gherkin" "$work/root" "$work/data"
echo "# fake" > "$work/src/docs/gherkin/index.md"
printf '{"kb_version":"9.9.9"}' > "$work/src/kb.manifest.json"
tar -czf "$work/kb.tar.gz" -C "$work/src" .
sha="$(shasum -a 256 "$work/kb.tar.gz" | awk '{print $1}')"
cat > "$work/root/kb-version.json" <<JSON
{"repo":"local/fake","version":"9.9.9","asset":"kb.tar.gz","sha256":"$sha"}
JSON
echo "$work/kb.tar.gz $sha $work/root $work/data"
