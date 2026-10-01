# spec-personas

Multi-persona review of any spec — PRD, RFC, design doc, or Gherkin — with mixture-of-agents
synthesis. Not BDD-specific.

## What it does

Reviews a spec from several stakeholder perspectives in parallel, then synthesizes their findings
into one prioritized report and an interactive refinement pass. Ships 17 ready personas and lets you
create your own.

## Components

- **Skills**
  - `spec-review` — fan out persona reviews, synthesize them, and interactively refine the spec.
  - `persona-manager` — create, edit, clone, and validate `.persona` files.
  - `persona-moa-synthesis` — persona framing for the synthesis step (used by `spec-review`).
  - `moa-synthesis` — general-purpose guide for using the `moa-synthesizer` agent to consolidate
    any multiple sources (reviews, research briefs, model outputs), not just personas.
- **Agents** — `persona-reviewer` (one run per persona), `moa-synthesizer` (generic multi-source
  synthesis engine), `persona-generator` (bulk-create personas), `spec-updater` (apply agreed changes).
- **Personas** — 17 curated `.persona` files; extend with your own.

## How to use

```
/plugin install spec-personas@bdd-workflow
```

Ask for a "multi-persona spec review of SPEC.md" and it fans out the reviews and returns a
synthesized report. Manage personas through `persona-manager` (e.g. "create a security-reviewer
persona").

## Where it fits

The review stage — sharpen a spec before building against it. It stands alone and depends on no other
plugin in this suite; it works on any document, Gherkin feature files included. See
[`examples/library-lending/personas/`](../../examples/library-lending/personas) for two worked personas.
