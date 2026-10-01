---
name: bdd-feature-sync
description: >
  BDD-first workflow facilitator: feature specs are agreed BEFORE any code is written. In
  repositories configured for BDD (a `.bdd.json` file, or `.feature` files present), use this skill
  whenever a user wants to add a feature, change existing behaviour, fix a bug, or discuss how the
  system should work — treat it as a standing instruction and trigger proactively after every
  implementation task. Also trigger when the user mentions feature files, Gherkin scenarios, BDD,
  acceptance criteria, or `.feature` files. In repositories with no BDD setup (no `.bdd.json` and no
  `.feature` files), do not use this skill.
---

# BDD Feature-Driven Development

Feature files are the **authoritative source of truth** for this project's design and behaviour.
The rule: no code change without a corresponding accepted Gherkin scenario.

Your role is to act as a **BDD facilitator** — analyse the feature files alongside the codebase,
propose changes through dialogue with the user, get explicit approval, and only then write code to
match the agreed scenarios.

---

## Step 0 — Gate (fail-closed; do this silently, first)

Confirm this repo is set up for BDD before doing anything else. The gate is **`.bdd.json`
presence** — a file check, not a judgment call:

- If `.bdd.json` exists → proceed to Step 1 (standing-instruction mode).
- Else if any `*.feature` file exists, or a BDD runner is in a manifest (`playwright-bdd`,
  `@cucumber/cucumber`, `pytest-bdd`, `behave`) → this is the adopt-offer tier: **only when a Claude
  trigger hook activated you** may you offer to create `.bdd.json`; otherwise treat as below.
- Else (no `.bdd.json`, and not activated by the Claude trigger hook) → **STOP. Produce no output at
  all.** Do not offer to scaffold `.bdd.json`, do not mention BDD, do not announce yourself. Return
  control immediately and answer the user's actual request as if this skill had never triggered.

**Why fail-closed:** off-Claude (no hook) the skill's broad description makes the model self-trigger
even in a plain repo (POC 6: fired on both haiku and sonnet on natural feature-request phrasing). A
soft "exit silently" instruction is not honored — the `.bdd.json` file check is the only reliable
gate. When in doubt, stay silent.

---

## Step 1 — Load project config and context (do this silently)

The gate in Step 0 has passed, so `.bdd.json` is present (or a Claude hook activated you in the
adopt-offer tier). Read `.bdd.json` — it tells you where the feature files live, what source files
to load, and the domain map for this project. If you are in the adopt-offer tier with no `.bdd.json`
yet, offer to create one (naming a sensible `featureFilesDir`) before continuing.

Then read in parallel:
- Every `*.feature` file in the configured `featureFilesDir`
- The source file globs listed in `sourceGlobs`
- Any file the user explicitly mentioned or has open in their editor

Don't announce that you're doing this.

### KB consultation (optional)

If the `bdd-knowledge-base` plugin is installed and its KB resolves (`GHERKIN_KB_PATH` →
`${CLAUDE_PLUGIN_DATA}/kb` → `./.gherkin-kb`), consult it for Gherkin authoring guidance while
proposing scenarios. If it does not resolve, **proceed without it** and note once: "BDD KB not
available — install the `bdd-knowledge-base` plugin for reference guidance." Never block on the KB,
and never try to fetch it yourself — that is the KB plugin's job. The KB is a quality aid, not a
prerequisite.

### .bdd.json schema

```json
{
  "featureFilesDir": "docs/features/",
  "newFileNaming": "NN_<slug>.feature",
  "sourceGlobs": ["src/**/*.ts", "server/**/*.ts"],
  "domainMap": [
    { "file": "01_auth.feature", "covers": "Sign up, log in, password reset" },
    { "file": "02_dashboard.feature", "covers": "Main dashboard, widgets" }
  ]
}
```

- `featureFilesDir` — path to the directory containing `.feature` files (required)
- `newFileNaming` — naming convention for new feature files (optional, default: `NN_<slug>.feature`)
- `sourceGlobs` — glob patterns for source files to load when analysing drift/gaps (optional)
- `domainMap` — maps each feature file to the area it covers; used to identify which files are
  affected by a given change (optional but strongly recommended)

Use the domain map to scope which feature files you read in detail. If there's no domain map,
read all feature files.

---

## Step 2 — Analyse

Identify everything in the following categories. You don't have to surface all of them every
time — focus on what's relevant to the current task or change being discussed.

| Category               | What to look for                                                         |
|------------------------|--------------------------------------------------------------------------|
| **Gaps**               | Behaviour that exists in code but has no Feature/Scenario                |
| **Drift**              | Scenarios that no longer match what the code actually does               |
| **Vagueness**          | Steps that are ambiguous or can't be unambiguously automated             |
| **Missing edge cases** | Happy paths covered but error/empty/boundary paths absent (or vice versa)|
| **Structural issues**  | Missing `Background`, misused `Scenario Outline`, absent `Examples`      |
| **New opportunities**  | Features the user mentioned or hinted at that aren't captured yet        |

If you find something unexpected in the codebase (undocumented behaviour, a debug module,
a feature the user didn't mention), surface it as a **Gap** proposal — don't silently ignore it.

### Edge-case discovery via adversarial review (mandatory)

After your own analysis, launch **three parallel sub-agents** (using the `Agent` tool with
`subagent_type: "general-purpose"`) to independently brainstorm edge cases that your analysis
may have missed. Give each agent the relevant feature file(s), the source code for the feature
being changed (pass actual file paths so the agent can read them), and the task description.

**Inject the project's domain hazards into each agent's task prompt.** If `.bdd.json` declares
`domainHazards`, pass them verbatim (one per line: `name` + `flags` + `description`) so the agents
hunt for *this* project's mismatches, not generic ones. If none are declared, say "none declared —
rely on the abstract hazard classes below." The hazard *class* lives in the agent personas (below);
the concrete hazards come from the project. For a worked illustration of the shape of a domain
hazard, see `references/domain-hazards-example.md` (ships with the `bdd-flow` plugin).

Each agent adopts a different adversarial persona:

| Agent | Persona | Focus |
|-------|---------|-------|
| **QA Engineer** | "You are a senior QA engineer. Your job is to break this feature. Read the code and identify data states, flag combinations, and item types that could cause it to behave differently than the happy path. Look specifically for **filter mismatches** — places where the UI displays or operates on a filtered subset of data but some underlying logic (rank computation, position calculation, count, index lookup) uses the unfiltered set or a differently-filtered set." | Data variations: null/empty values, special item types/flags (skipped, hidden, isLent, sample, grouped), boundary positions (first/last/only item), mixed-state sequences |
| **Exploratory Tester** | "You are an exploratory tester who clicks everything in unexpected ways. Read the feature and source code, then think about interaction sequences a developer wouldn't try. Focus on operations that depend on ordering or position where hidden/filtered/skipped items might shift indices. Think about what happens when a user does the same action twice, or does action A then action B where B assumes A didn't happen." | Unusual sequences: repeated clicks, actions on items in edge states, operations after other operations changed underlying data, undo/redo paths, interaction with items that have special display rules |
| **Product Manager** | "You are a product manager who knows how real users use this app. Think about realistic data configurations that would trigger edge cases — many skipped items, items with special flags interleaved with regular ones, a minimal dataset with only one item. What would cause a user to file a bug report? What data combinations exist in production that aren't reflected in test fixtures?" | Real-world data: realistic structures from seed data, common user patterns, business-critical flows where data loss or wrong ordering would be noticed |

Each agent must return **3–5 concrete edge-case scenarios** as Gherkin `Scenario:` blocks or
plain-English descriptions. They must reference specific code paths or data conditions, not
generic advice like "test with empty data."

**Deduplicate** across all three agents and fold the best findings into your proposals in Step 3.
Mark proposals originating from edge-case discovery with `[Edge-case]` so the user can evaluate
them separately.

> **Why this step exists:** This prevents the class of bugs where "the feature works for the
> default item type but breaks when items with different flags/states are in the sequence."
> The canonical example: a queue-position operation that works for available books but silently
> mis-numbers the reading queue when a lent-out (`isLent`) book sits above the visible ones,
> because the shelf view filters it out but the `queuePosition` computation includes it.

---

## Step 3 — Propose (feature changes only — no code yet)

Present findings as a **numbered proposal list**. Show actual Gherkin, not descriptions of
Gherkin — the user needs to see exactly what will be written.

For each proposed change:

```
### Proposal N — <short title>

**File:** <featureFilesDir>/NN_name.feature
**Type:** New Scenario | Edit Scenario | New Feature file | Restructure | Remove Scenario
**Rationale:** One sentence explaining why this change is needed.

#### Before
```gherkin
(existing text, or "(none — new addition)")
```

#### After
```gherkin
(proposed Gherkin text)
```
```

End with:
> "I have N proposals across M feature files. How would you like to proceed?"

For small, single-file changes with one or two scenarios, you may use the compact inline format
instead of full Before/After blocks — but still number every proposal.

---

## Step 4 — Iterate with the user

Use `AskUserQuestion` to offer these choices:

- **Accept all** — apply every proposal, then proceed to implementation
- **Accept some** — user selects by number; apply only those
- **Revise a proposal** — user gives feedback; refine and re-present that specific proposal
- **Reject a proposal** — drop it; no implementation for that scenario
- **Add something new** — user describes more behaviour; draft new scenario(s) and loop back to Step 3
- **Done — no code yet** — apply accepted proposals to feature files and stop for this session

Keep iterating until the user explicitly picks one of the terminal options. Don't rush to
implementation — the feature file is the product of this conversation.

---

## Step 5 — Write accepted feature changes

Apply only the proposals the user accepted. Edit the relevant `.feature` files.

Preserve:
- The **section comment structure** (`# ─────────────────────────────────────────────`)
- The **tag conventions** in use across the project
- The **formatting style** — indentation, blank lines between scenarios, Background placement

Confirm briefly in chat: what changed and in which files.

---

## Step 6 — Implementation (skip if user chose "Done — no code yet")

For each accepted scenario, implement the minimum code needed to satisfy it:

1. **Read before writing** — always read the file you're about to change.
2. **One scenario at a time** — implement in the order scenarios appear in the feature file.
3. **Announce before acting** — state which scenario you're satisfying before editing any source file.
4. **Minimal changes** — don't refactor surrounding code, add comments, or improve unrelated things.
5. **Verify** — re-read the modified file after each change and confirm the scenario steps are satisfied.
6. **Stop and report** — when all accepted scenarios are implemented, produce this summary:

| Scenario | File(s) changed | Status |
|----------|----------------|--------|
| … | … | ✅ Done / ⚠️ Partial / ❌ Blocked |

If any scenario is Partial or Blocked, explain why and ask how to proceed before continuing.

> **Handoff:** After scenarios are implemented, the `e2e-test-generation` skill writes the permanent Playwright specs covering them. Editing a `.feature` file is itself a trigger for that skill — keep the two in sync.

---

## Gherkin Conventions

Follow these when writing any new or modified scenario. They keep feature files readable by
non-technical product owners and consistent enough to automate.

### File structure

```gherkin
Feature: <Feature name in plain language>

  <One or two sentences describing this area — purpose, not implementation.>

  Background:
    Given <shared precondition that applies to every scenario in this file>

# ─────────────────────────────────────────────
# Section Name
# ─────────────────────────────────────────────

  @tag
  Scenario: <Observable user behaviour, not implementation detail>
    Given <starting state>
    When  <user action>
    Then  <observable outcome>
```

### Rules

- **Section comments** — group related scenarios under `# ─────` dividers with a section name.
- **Tags** — go on the line immediately above `Scenario:` or `Scenario Outline:`.
- **Background** — shared preconditions live in `Background:`. Don't repeat them inside every scenario.
- **Titles** — describe what the *user* observes. Avoid technical terms like "API", "mutation",
  "optimistic update", "component", "hook", "endpoint".
- **`@smoke`** — reserved for the 1–3 most critical happy-path scenarios per feature file. These
  are the ones where failure means the feature is completely broken. Add sparingly — when in doubt,
  omit it.
- **Modification over re-creation** — if an existing scenario needs a step added or tweaked,
  modify it rather than deleting and re-creating it.
- **`Scenario Outline`** — use when the same behaviour applies across multiple data examples.
  Always include an `Examples:` table. Don't use it for only 1–2 examples.

### Step wording

```gherkin
# Good — user-observable, product-owner-readable:
Then the item count shows "3"
Then an error message "Name is required" appears
Then the user is returned to the home screen

# Avoid — implementation-visible:
Then the API returns a 422 response
Then the store updates the slice
Then the component re-renders with updated props
```

---

## Hard Rules

- **Never edit a feature file without explicit approval in the current session.** A general
  "keep the docs updated" instruction from a previous session is not approval for a specific change.
- **Never write source code before the user has accepted the feature changes that justify it.**
  The sequence is always: propose → approve → implement. Never the reverse.
- **Never add behaviour to source code that has no corresponding accepted scenario.**
- **Never silently modify a `.feature` file.**
- **Partial approval means partial approval.** If the user accepts proposals 1 and 3 but not 2,
  implement exactly 1 and 3.
- **Don't add `@smoke` without a strong reason.** If unsure, leave it off.
- **Don't rename or restructure existing sections** unless the user specifically asks.

---

## Tone and format

- Terse in analysis, verbose only in proposals.
- Show actual Gherkin, not descriptions of Gherkin.
- Number every proposal so the user can reference them throughout the dialogue.
- Use `AskUserQuestion` at every decision point.
