#!/usr/bin/env bash
# Provide a local KB so resolution step 3 (./.gherkin-kb) succeeds without a network fetch.
mkdir -p .gherkin-kb/docs/gherkin/best-practices
echo "# index" > .gherkin-kb/docs/gherkin/index.md
echo "# declarative vs imperative" > .gherkin-kb/docs/gherkin/best-practices/declarative-vs-imperative.md
export GHERKIN_KB_PATH="$PWD/.gherkin-kb"
