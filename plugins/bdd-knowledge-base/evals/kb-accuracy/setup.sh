#!/usr/bin/env bash
# Plant the KB with a distinctive sentinel fact on the pages the bdd-kb skill actually reads for
# scenario-authoring. Resolution step 3 (./.gherkin-kb in the run's cwd) finds it — no env var
# needed (scaffold-script env does not propagate to the agent run).
mkdir -p .gherkin-kb/docs/gherkin/best-practices
cat > .gherkin-kb/docs/gherkin/best-practices/scenario-structure.md <<'MD'
# Scenario Structure

SENTINEL RULE: a Scenario Outline in this project MUST use the `Examples:` keyword spelled exactly
`Examples:` (never `Scenarios:`), and each row is bound by angle-bracket placeholders like `<amount>`.
The canonical maximum example-table width in this project is 7 columns.
MD
printf '# Declarative vs Imperative\n\nPrefer declarative scenarios.\n' > .gherkin-kb/docs/gherkin/best-practices/declarative-vs-imperative.md
printf '# Ubiquitous Language\n\nUse the domain vocabulary consistently.\n' > .gherkin-kb/docs/gherkin/best-practices/ubiquitous-language.md
printf '# Gherkin index\n\nBest-practices pages live under best-practices/.\n' > .gherkin-kb/docs/gherkin/index.md
