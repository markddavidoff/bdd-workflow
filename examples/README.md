# Examples

Worked examples of the BDD workflow end to end, so you can see what the plugins produce before
running them on your own project.

- [`library-lending/`](library-lending/) — the finished artifacts + the spec-first change story (uses a
  `node --test` suite; stack-neutral).
- [`library-lending-playwright/`](library-lending-playwright/) — the same example wired for
  **`playwright-bdd`** (the flagship JS/Playwright path), with real step definitions and a verified run.

## `library-lending/`

A small library book-lending project in its finished state — the artifacts the workflow produces,
plus the spec-change story that shows the workflow's core rule in action.

| Path | What it is | Which plugin/skill produces it |
|------|------------|--------------------------------|
| `.bdd.json` | Project config: where features and tests live, plus a `domainHazards` entry the review agents inject | `bdd-scaffold` |
| `personas/librarian.persona`, `personas/patron.persona` | Two review perspectives with real tension over hold-queue fairness | `spec-personas` (`persona-manager`) |
| `docs/features/lending.feature` | The Gherkin spec: borrow, hold queue, and queue-respecting returns | `bdd-flow` (`bdd-feature-sync`) |
| `tests/lending.test.js` | A `node --test` suite matching the scenarios | `bdd-flow` (`e2e-test-generation`) |
| `src/lending.js` | A toy implementation that satisfies the spec | written to pass the tests |
| `SPEC-CHANGE.md` | The spec-first change story: a behavior change entering through the spec, regenerating a test, then driving the implementation | `bdd-flow` (spec-first gate) |

### Get it and run it

This folder is part of the repository, not the plugin marketplace install. Clone the repo to get it:

```bash
git clone https://github.com/markddavidoff/bdd-workflow
cd bdd-workflow/examples/library-lending
node --test        # all scenarios pass against the implementation
```

### See the plugins actually do it

[`SESSION-TRANSCRIPT.md`](SESSION-TRANSCRIPT.md) is a real captured Claude Code session — install the
plugins, ask for a feature change, and watch the skill fire, the review agents run, and the spec-first
gate hold for approval. That is the "type this, see this" view the static files can't show.

The repo's `tests/examples.bats` runs exactly this in CI, and validates `.bdd.json` against
`schemas/bdd-config.schema.json`, so the example stays correct as the project evolves rather than
drifting into stale documentation.

### The spec-first story

`SPEC-CHANGE.md` walks through the change that gives the two personas something to disagree about:
a returned book used to go to whoever asked next; now it is reserved for the next patron on the
hold queue. The point is the order — the spec changes first, the test regenerates from it, and the
implementation follows.
