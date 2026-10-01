---
name: persona-moa-synthesis
description: >
  Persona configuration for MoA synthesis. Use during a multi-persona spec review (invoked by
  spec-review's synthesis phase) to consolidate independent persona reviews into one report:
  it maps each persona review to a weighted source and dispatches the generic moa-synthesizer
  agent, requesting the persona-specific output (consolidated gaps, conflicts as decision points,
  and interview questions for the product owner).
---

# persona-moa-synthesis — Persona MoA Configuration

This is the persona-specific layer over the generic `moa-synthesizer` agent. It does NOT contain the
aggregation logic itself (that lives in the agent) — it supplies the persona framing: which sources,
what weights, and the exact output shape a spec review needs.

## When to use

During Phase 3 of a multi-persona spec review, after each persona has written its review to
`reviews/{persona.id}-review.md`. Apply this skill to produce `reviews/synthesis.md`.

## How to dispatch

Dispatch the **`moa-synthesizer`** agent with these inputs:

- **SOURCES:** every `reviews/{persona.id}-review.md` produced in this review.
- **WEIGHT:** each persona's `weight` field becomes that source's weight.
- **VANTAGE:** each persona's role/expertise becomes that source's vantage (e.g. a QA engineer's
  view weighs more on state machines; a CEO's weighs more on pricing/scope).
- **SUBJECT CONTEXT:** the spec under review (reference feature numbers and scenarios).
- **REQUESTED OUTPUT SHAPE:** the persona output contract below.

Write the agent's result to `reviews/synthesis.md`.

## Requested output shape (the persona contract)

```markdown
# Consolidated Persona Review — Synthesis Report

## Review Panel
The personas who participated, each with a one-line role summary.

## Critical Gaps (Blocking for v1)
Issues raised by 2+ personas, or high-severity from a single expert persona. Table:
| # | Gap | Raised By | Severity | Recommendation |

## High-Priority Improvements
Important but not blocking. Same table format.

## Nice-to-Have (v1.1 Candidates)
Lower priority. Same table format.

## Conflicts & Decision Points
Where personas disagree. For each: **Issue**, **Position A** ([personas] argue [position] because
[reasoning]), **Position B** (likewise), **Recommendation** (what the product owner should consider —
do not silently resolve).

## Interview Questions
Deduplicated, prioritized questions for the product owner, grouped by topic. For each: the question
(framed as a decision with options), which personas it addresses, and why it matters (one sentence).
Order questions to maximize information gain (early answers inform later ones). Aim for 15–25 total.

## Improvement Recommendations
Specific, actionable spec changes ordered by priority, each referencing feature numbers/scenarios and
implementable by a spec writer without further clarification.
```

## Quality criteria (persona-specific)

- Every gap cites at least one specific feature/scenario in the spec.
- Every interview question is answerable (not rhetorical) and offers structured options where possible.
- Conflicts present both sides fairly.
- The report is self-contained — a reader who has not seen the individual persona reviews understands
  everything.
