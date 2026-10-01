# bdd-flow

Author and evolve Gherkin feature specs with adversarial edge-case review, and generate their
tests — spec first, on any stack.

## What it does

bdd-flow keeps `.feature` specs the source of truth. Ask for a behavior change in a BDD project and
it proposes the spec change first, runs an adversarial review to surface edge cases, and holds for
your approval before any source is written. Once a spec is agreed, it generates the matching tests.
Stack-neutral; consults `bdd-knowledge-base` for Gherkin guidance when that plugin is installed.

## Components

- **Skills**
  - `bdd-feature-sync` — the spec-first workflow: propose the `.feature` change, review it, gate on approval.
  - `e2e-test-generation` — generate Playwright / `node --test` specs from a feature.
- **Review agents** (dispatched by `bdd-feature-sync`): `qa-engineer`, `exploratory-tester`,
  `product-manager`, `coverage-gap` — each critiques the proposed spec from its angle.
- **Hook** — `detect-bdd` (UserPromptSubmit): detects whether the project is BDD-configured and routes accordingly.
- **References** — `domain-hazards-example.md`: how to declare project-specific hazards the review agents inject.

## How to use

```
/plugin install bdd-flow@bdd-workflow
```

In a project with a `.bdd.json`, ask for a behavior change (e.g. "add a password-reset scenario to
auth"). bdd-flow proposes the spec plus edge cases, waits for your sign-off, then generates tests.
Not BDD-configured yet? Run `bdd-scaffold` first.

## Where it fits

The authoring + review + test-generation stage: **scaffold → (author/change spec + review) →
generate tests → implement**. See the repo root [README](../../README.md) for the full lifecycle and
[`examples/library-lending/`](../../examples/) for a worked example.
