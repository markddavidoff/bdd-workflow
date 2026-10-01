---
name: bdd-tutorial
description: >
  Interactive, adaptive onboarding walkthrough for the BDD workflow toolkit. Run when a
  user is new to these plugins, asks how to get started, wants a guided tour, or invokes
  /bdd-tutorial. Assesses what the user already knows, then either tours the library-lending
  example hands-on or delegates to persona-manager / bdd-feature-sync to start real BDD
  artifacts for the user's own project.
---

# bdd-tutorial — Guided Onboarding Walkthrough

You are running an adaptive onboarding walkthrough. Keep it to ~5 minutes. Ask ONE question at
a time. Skip any concept the user already knows. Be concise — no walls of text.

## Answerless / non-interactive guard

Key this on what you can actually detect: **can you get answers from the user?** If you cannot —
a non-interactive/headless run, or a request that gives you nothing to respond to — do NOT run the
branch tree and do NOT invent answers on the user's behalf. Instead print a short static overview:
what the toolkit is, the four plugins, and "run `/bdd-tutorial` in an interactive session for the
guided walkthrough." Then stop. (When the user's message already supplies the answers, proceed
normally — a single message that answers the questions is not "answerless".)

## Stage 1 — Adaptive knowledge check (one question at a time; skip the known)

1. Ask: "Have you used this BDD toolkit before, or want a quick overview of what it is?"
   If they want it: 3 lines — it's a set of Claude Code plugins for a BDD workflow (author
   Gherkin features with adversarial edge-case review, KB-backed guidance, Playwright specs,
   multi-persona spec review), backed by a versioned BDD knowledge base.
2. Ask: "Do you know what BDD is?" If no: 3 lines — Behavior-Driven Development: describe
   behavior as concrete Given/When/Then scenarios agreed BEFORE code; those scenarios become
   living tests. For depth, mention they can use the `bdd-kb` skill.
3. Ask: "Do you know what review personas are here?" If no: 3 lines — named stakeholder
   viewpoints (e.g. QA, product, security) that review a spec in parallel to surface gaps.

## Stage 2 — Action menu (present as a numbered list; then route)

Present these choices and route to the selected one:

1. **Walk through a BDD example (hands-on).** Tour `examples/library-lending`: open
   `docs/features/lending.feature`, replay the spec-first story in `SPEC-CHANGE.md`
   (spec → test → impl), and run its tests. READ-ONLY — do not modify the example.
   If `examples/library-lending/` is not present (you are in an installed plugin, not the repo),
   show a short inline `.feature` snippet instead and tell the user: "clone
   `markddavidoff/bdd-workflow` and `cd examples/library-lending` to run it live."
2. **Full workflow walkthrough.** Narrate the loop on the example: feature authoring →
   adversarial edge-case review → test generation. (Read-only narration in v1.)
3. **Generate personas for MY project.** Explain that you will invoke the `persona-manager`
   skill and what it will ask, then invoke it. If `spec-personas` is not installed, say:
   "install `spec-personas@bdd-workflow` to use this" and offer another choice.
4. **Generate initial scope/features for MY project.** Explain you will invoke the
   `bdd-feature-sync` skill, then invoke it. If `bdd-flow` is not installed, say: "install
   `bdd-flow@bdd-workflow` to use this" and offer another choice.
5. **Analyze my whole project now (auto-generate personas + BDD docs).** NOT YET AVAILABLE.
   Say: "Coming soon — this will auto-generate personas and a BDD doc set from your codebase.
   For now, use choices 3 and 4 to do this step-by-step." Do not attempt it.

## Delegation contract

For choices 3 and 4 you MUST hand off to the real skill (do not reimplement persona or scope
generation here). Set context first (name the skill, say what it asks), then invoke it.

## Re-run

`/bdd-tutorial` always restarts from Stage 1.
