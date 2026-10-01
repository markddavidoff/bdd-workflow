---
name: moa-synthesis
description: >
  Use to consolidate MULTIPLE independent sources — several reviews, research briefs, model
  outputs, or analyses of the same subject — into one synthesis that is better than any single
  source. Trigger when you have N sources to reconcile (not a single doc to summarize) and you
  want consensus surfaced, genuine disagreement preserved as decision points, duplicates merged,
  and cross-source insight drawn out. Dispatches the moa-synthesizer agent.
---

# moa-synthesis — Mixture-of-Agents Synthesis (general)

Use this when you have **several independent sources about the same subject** and need one
consolidated report. It is the general-purpose entry point to the `moa-synthesizer` agent; a plain
summary flattens sources, whereas MoA synthesis weighs them, keeps disagreement visible, and finds
what no single source said.

## When it beats a plain summary

- Multiple reviewers/analysts each produced findings and you need one prioritized view.
- Several models (or several runs) answered the same question and you want the strongest combined
  answer with disagreements surfaced, not averaged away.
- A set of research briefs overlap and conflict, and you need the consensus plus the open questions.

If you only have ONE source, you do not need this — just read it.

## Input contract

Dispatch the **`moa-synthesizer`** agent (via the Agent/Task tool) with:

- **SOURCES** — the documents to reconcile (paths or inline). Aim for 2+.
- **WEIGHT** (optional, per source) — how much influence each should carry.
- **VANTAGE** (optional, per source) — a one-line note on each source's expertise, so the agent can
  weight opinions by topic.
- **REQUESTED OUTPUT SHAPE** (optional) — the exact sections you want; if omitted, the agent uses its
  default (Consensus / Divergences / Novel Insights / Prioritized Synthesis / Open Questions).
- **SUBJECT CONTEXT** (optional) — what the sources are about, so claims cite specifics.

The agent returns one Markdown synthesis; write it wherever the caller needs it.

## Worked examples

1. **Consolidating research briefs.** Three briefs each assess a database choice. Dispatch with the
   three files as SOURCES, weight the one written by the on-call engineer higher (VANTAGE:
   "operational experience"), request the default output. Result: the shared recommendation as
   consensus, the cost-vs-latency disagreement as a decision point, and a migration risk only visible
   across all three.

2. **Aggregating multiple model answers.** You asked five models the same design question and saved
   each answer. Dispatch all five as equal-weight SOURCES; request an output shape of "Best combined
   answer / Points of disagreement / Confidence." Result: one answer stronger than any single model's,
   with the genuine splits called out instead of silently majority-voted.

3. **Merging multi-reviewer findings.** Several reviewers filed notes on the same document. Dispatch
   the notes as SOURCES with per-reviewer VANTAGE; request "Blocking issues / Nice-to-haves / Open
   questions." Result: deduplicated, prioritized findings with attribution.

## Why an agent (not inline)

Synthesis ingests many source documents; running it in the `moa-synthesizer` subagent keeps that bulk
out of your own context and lets it run on a strong model. Dispatch it; keep the returned report.
