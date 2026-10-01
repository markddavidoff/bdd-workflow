# bdd-workflow

A source-available toolkit of Claude Code plugins for behavior-driven development:
feature authoring with adversarial edge-case review, knowledge-base-backed Gherkin
guidance, Playwright spec generation, and multi-persona spec review.

> Personal project · source-available · **not** open-source · **no warranty** · forking discouraged.
> **Not affiliated** with Anthropic, SmartBear, Cucumber, or Microsoft.

## Prerequisites — Claude Code

These are plugins for **[Claude Code](https://code.claude.com/docs)**, Anthropic's agentic coding
tool that runs in your terminal (also available in the desktop and IDE extensions). If you don't have
it yet, install it and sign in first — see the [Claude Code docs](https://code.claude.com/docs). Once
`claude` starts an interactive session, you type the `/plugin …` commands below **at its prompt**, not
in your shell.

## New to BDD?

**Behavior-driven development (BDD)** writes down how software should behave — in plain,
structured sentences — *before* you build it, and keeps those sentences as the source of truth. The
behavior lives in **`.feature` files** written in **Gherkin**, a small `Given / When / Then` syntax:

```gherkin
Scenario: A returned book is reserved for the next patron in line
  Given Ada has borrowed the only copy of "Dune"
  And Grace is on the hold queue for "Dune"
  When Ada returns "Dune"
  Then "Dune" is reserved for Grace
```

The payoff: the spec is executable-adjacent (tests are generated from it), changes are deliberate
(you edit the spec first and re-derive the tests), and non-programmers can read and agree to it. This
toolkit gives Claude Code the knowledge and structure to work that way. If the terms above are new,
see the [Glossary](#glossary) and the reference in
[bdd-knowledge-base](https://github.com/markddavidoff/bdd-knowledge-base).

## Quickstart (5 minutes)

**Brand new to BDD or to this toolkit?** Install `bdd-knowledge-base` and run **`/bdd-tutorial`** — a
guided, adaptive walkthrough that orients you and can set up BDD on your own project:

```
# In a Claude Code session (type these at the claude prompt):
/plugin marketplace add markddavidoff/bdd-workflow
/plugin install bdd-knowledge-base@bdd-workflow
/bdd-tutorial
```

**Ready to author specs?** The fastest path to seeing the workflow work — one plugin, one prompt, one
result:

```
# In a Claude Code session (type these at the claude prompt):
/plugin marketplace add markddavidoff/bdd-workflow
/plugin install bdd-flow@bdd-workflow
```

`/plugin install` prints a confirmation line (`Successfully installed plugin: bdd-flow@bdd-workflow`).
Then, in a project that has a `.bdd.json` (run `bdd-scaffold` first if it doesn't — see below), ask:

> *"Add a password-reset scenario to the auth feature."*

bdd-flow proposes the `.feature` change, runs an adversarial edge-case review, and **holds for your
approval before writing anything** — the spec-first gate in action. Approve, and it writes the spec
and generates tests. A full worked run is in [`examples/`](examples/), including a real session
transcript.

**Verify / troubleshoot:** `/plugin list` should show `bdd-flow@bdd-workflow` as enabled. If the
marketplace add fails, confirm you're at the `claude` prompt (not your shell) and signed in; if a
skill doesn't fire, make sure the project has a `.bdd.json`.

## Goals

Keep behavior specs the source of truth, make spec changes deliberate — proposed, reviewed, and
approved before code — and give Claude Code the BDD knowledge and structure to work that way. The
pieces are à la carte: install only what you need.

## The BDD workflow

The plugins cover one lifecycle; each stage is optional and independently installable.

1. **Scaffold** — `bdd-scaffold` adds `.bdd.json` and templates to a project.
2. **Author or change a spec** — `bdd-flow` proposes the `.feature` change and its review agents
   surface edge cases, backed by `bdd-knowledge-base` guidance.
3. **Review** — `spec-personas` reviews the spec from multiple stakeholder perspectives.
4. **Approve** — a spec-first gate: nothing is written to source until you sign off.
5. **Generate tests** — `bdd-flow` turns the agreed spec into tests.
6. **Implement** — write code to pass the tests; a later behavior change starts again at step 2.

A worked, verified example — personas, spec, tests, a toy feature, and a spec-first change — lives in
[`examples/library-lending/`](examples/).

## Which plugin do I need?

Four à-la-carte plugins — each installs **separately** and works on its own; install only what you
need. They have no plugin-to-plugin install dependency, and they integrate when combined (e.g.
`bdd-flow` consults `bdd-knowledge-base` if it's installed). One project-level expectation, not a
plugin dependency: `bdd-flow`'s authoring needs a `.bdd.json` in your project — create one with
`bdd-scaffold` or by hand.

| Plugin | Use it when | Ships |
|---|---|---|
| **bdd-flow** | You write `.feature` files and want adversarial edge-case review and Playwright spec generation. Stack-neutral authoring. Consults `bdd-knowledge-base` when it is installed. | `bdd-feature-sync`, `e2e-test-generation` skills + 4 review agents |
| **bdd-knowledge-base** | You want the curated Gherkin/BDD reference on hand — fetched, pinned, and verified — to query directly or to back `bdd-flow`. A good **start-here** if BDD is new to you. | `bdd-kb` skill + the KB fetch hook + `/bdd-kb-sync`, `/bdd-kb-clean` |
| **spec-personas** | You want multi-persona review of *any* spec (PRD, RFC, design doc) with MoA synthesis. Not BDD-specific. | `spec-review`, `persona-manager` skills + 4 agents + 17 personas |
| **bdd-scaffold** | You want to add BDD to a project from scratch: `.bdd.json`, feature/step templates, Playwright + CI wiring. **JS/Playwright-first** (see stack note). | `bdd-scaffold` skill |

The **knowledge base** — the Gherkin/BDD reference the `bdd-kb` skill reads — ships **only in
bdd-knowledge-base**. Install any of the other three alone and no KB is ever fetched.

> **Two things named `bdd-knowledge-base`:** the *plugin* here (the `bdd-kb` skill + fetch hook) and
> the separate *content repo* [bdd-knowledge-base](https://github.com/markddavidoff/bdd-knowledge-base)
> (the Gherkin/BDD dataset itself). The plugin fetches the content repo's releases.

> **Stack coverage:** the methodology, KB, and `bdd-flow` authoring are stack-agnostic, and the KB's
> Gherkin core applies to any runner. But the **deep runner guidance and `bdd-scaffold` wiring are
> Playwright/JS-first**; cucumber-js, cucumber-jvm, pytest-bdd, behave, and reqnroll have lighter
> overviews for now. If you're on a non-JS stack, the authoring + KB still help; the scaffolding does not.

## Glossary

**Claude Code terms**
- **Marketplace** — a source of plugins you register with `/plugin marketplace add`.
- **Plugin** — an installable bundle of skills, agents, hooks, and commands.
- **Skill** — instructions Claude Code loads when a task matches, teaching it a workflow.
- **Agent** — a sub-task Claude runs in its own context (here, the review perspectives).
- **Hook** — a script the harness runs automatically on an event (e.g. session start); the only one
  here that touches the network is the KB fetch, and it is disclosed and opt-out-able below.
- **Command** — a `/name` action a plugin adds (e.g. `/bdd-kb-sync`).

**BDD terms**
- **Gherkin** — the `Given / When / Then` language for writing scenarios.
- **`.feature` file** — a file of Gherkin scenarios describing one feature's behavior.
- **Scenario** — one concrete example of behavior (a `Given/When/Then` block).
- **Step definition** — code that binds a Gherkin step to an action in a test.
- **Spec-first** — change the `.feature` spec (with review + approval) before changing code.

## Hooks & the knowledge base (download disclosure)

The `bdd-knowledge-base` plugin backs its `bdd-kb` skill with a local BDD knowledge base. On first
use, its `SessionStart` hook fetches a pinned, sha256-verified release of the `bdd-knowledge-base`
dataset (a few MB) into the plugin's data directory, then costs one `diff` per session with no further
network. This is the **only** network fetch any of these plugins make. It announces itself on first
fetch and can be disabled or redirected (see Uninstall / opt-out). Install `bdd-flow`,
`spec-personas`, or `bdd-scaffold` without `bdd-knowledge-base` and no fetch ever happens.

## Offline behavior

The plugins work offline once the KB is present. If the KB has not been fetched and the network is
unavailable, `bdd-kb` tells you the KB is not installed and stops — it never guesses paths and never
blocks your session. Set `GHERKIN_KB_PATH` to a local copy, or run the manual bootstrap in the
`bdd-kb` skill, to avoid any fetch.

## Uninstall / opt-out

- Remove a plugin: `/plugin uninstall bdd-knowledge-base@bdd-workflow`.
- Disable the KB fetch without uninstalling: set `GHERKIN_KB_DISABLE=1`.
- Point at your own KB copy instead of fetching: set `GHERKIN_KB_PATH=/path/to/kb`.
- Remove the downloaded KB cache: run `/bdd-kb-clean`.

## Contributing & development

Issues are welcome; pull requests are not accepted under this license (see
[CONTRIBUTING.md](CONTRIBUTING.md)). Tests run in two tiers — a keyless install-smoke E2E on every
push and real behavior evals nightly. See [docs/EVALS.md](docs/EVALS.md).

## License, warranty & affiliation

This is a **personal, source-available project** — not open-source. You may install and use it,
including for internal use at a company, with attribution; you may **not** create derivative works or
redistribute modified versions. See [LICENSE](LICENSE), [NOTICE](NOTICE), and
[CONTRIBUTING.md](CONTRIBUTING.md) for the exact terms and contribution policy.

**No warranty.** The software is provided "as is", with **no warranty** of any kind; the author is not
liable for any damages. The plugins run shell commands (including a network fetch and file removal) on
your machine — review the source before use. See [SECURITY.md](SECURITY.md) for the disclosure path.

**Not affiliated.** This project is **not affiliated** with, endorsed by, or sponsored by Anthropic,
**SmartBear**, Cucumber (Gherkin), or Microsoft. All trademarks are the property of their respective owners.
