---
name: spec-review
description: >
  Multi-persona spec review and interactive refinement workflow. Use this skill
  whenever the user wants to review a specification document (Gherkin BDD, PRD,
  technical spec, RFC, design doc) from multiple stakeholder perspectives, run
  an interactive interview to resolve gaps, and produce an improved spec.
  Also use when the user mentions "persona review", "stakeholder review",
  "multi-perspective review", "review my spec", "review from different viewpoints",
  or wants to iterate on a spec with feedback from configurable reviewer personas.
  This skill uses parallel sub-agents for each persona and MoA-inspired synthesis.
---

# Multi-Persona Spec Review

A Claude Code skill that reviews specification documents from multiple configurable
stakeholder perspectives using parallel sub-agents, synthesizes feedback using a
Mixture-of-Agents (MoA) inspired aggregation layer, and drives interactive
interviews to resolve gaps and produce improved specs.

## Architecture

```
                    ┌─────────────────┐
                    │   Orchestrator   │
                    │   (this skill)   │
                    └────────┬────────┘
                             │ reads personas/*.persona
                             │ fans out parallel sub-agents
            ┌────────────────┼────────────────┐
            ▼                ▼                ▼
   ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
   │  Persona A   │ │  Persona B   │ │  Persona N   │
   │  Sub-Agent   │ │  Sub-Agent   │ │  Sub-Agent   │
   │  (reviewer)  │ │  (reviewer)  │ │  (reviewer)  │
   └──────┬───────┘ └──────┬───────┘ └──────┬───────┘
          │                │                │
          └────────────────┼────────────────┘
                           ▼
                ┌─────────────────────┐
                │  Synthesis Agent    │
                │  (MoA Aggregator)   │
                │  Sees ALL reviews   │
                └─────────┬───────────┘
                          ▼
              ┌───────────────────────┐
              │  Consolidated Report  │
              │  + Interview Questions│
              └───────────┬───────────┘
                          ▼
              ┌───────────────────────┐
              │  Interactive Interview│
              │  (user answers Qs)    │
              └───────────┬───────────┘
                          ▼
              ┌───────────────────────┐
              │  Spec Updater Agent   │
              │  Produces improved    │
              │  spec version         │
              └───────────────────────┘
```

## Workflow Phases

### Phase 1: Setup

1. Identify the spec file to review (user provides or points to a file)
2. Load all `.persona` files from the `personas/` directory
3. Show the user which personas will review and allow them to add/remove/edit
4. Read the spec into memory

### Phase 2: Parallel Persona Review

For each loaded persona, spawn a **parallel sub-agent** using the `persona-reviewer`
agent definition. Each sub-agent receives:

- The persona definition (role, goal, backstory, focus_areas, concerns, style)
- The full spec content
- Instructions to produce structured review output

**Sub-agent prompt template:**

```
You are reviewing a specification document as the following persona:

**Name:** {persona.name}
**Role:** {persona.role}
**Goal:** {persona.goal}
**Backstory:** {persona.backstory}
**Focus Areas:** {persona.focus_areas | join(", ")}
**Key Concerns:** {persona.concerns | join("\n- ")}
**Communication Style:** {persona.style.tone}, {persona.style.detail} detail, {persona.style.stance} stance

Review the following specification and provide feedback structured as:

## Strengths
What this spec does well from your perspective.

## Concerns & Gaps
What's missing, unclear, risky, or problematic. Be specific — cite the
feature number and scenario where relevant.

## Questions for the Product Owner
3-5 questions you'd ask the product owner to resolve ambiguities.
Frame each as a decision to be made, not an open-ended discussion.

## Verdict
One paragraph summary of your overall assessment.

---

SPECIFICATION TO REVIEW:

{spec_content}
```

**Key: launch all persona sub-agents in parallel in a single message** using the
Agent tool. Do NOT run them sequentially. Claude Code supports up to 10 concurrent
sub-agents.

Write each persona's review output to: `reviews/{persona.id}-review.md`

### Phase 3: MoA Synthesis

After all persona reviews complete, apply the **`persona-moa-synthesis`** skill. It is the
authoritative definition of the persona synthesis: it maps each persona review to a weighted source
(by the persona's `weight` field and role) and dispatches the generic **`moa-synthesizer`** agent,
requesting the full persona output contract — the consolidated gap tiers, conflicts as decision
points, interview questions for the product owner, and improvement recommendations. See that skill
for the exact section contract; do not re-specify it here (one source of truth avoids drift).

The underlying aggregation is MoA-inspired: it weighs persona feedback rather than concatenating,
identifies consensus vs. divergence, and preserves conflicts as decision points rather than silently
resolving them.

Write synthesis output to: `reviews/synthesis.md`

### Phase 4: Interactive Interview

Present the interview questions to the user interactively:
- Group questions by topic (3-5 questions per batch)
- For each question, offer structured choices where possible (single-select, multi-select)
- Capture freeform context when the user provides it
- Record all decisions in a structured decision log

Write the decision log to: `reviews/decisions.md`

### Phase 5: Spec Update

Spawn the **spec-updater** agent with:
- The original spec
- The synthesis report
- The decision log (user's answers)

The updater produces a new version of the spec incorporating all decisions,
resolving all open questions, and adding new features/scenarios identified
in the review. It preserves the original spec's format and style.

Write the updated spec to the original spec's directory with an incremented
version number.

### Phase 6: (Optional) Re-review

The user can request another review round. If so, return to Phase 2 with
the updated spec. Personas can be reconfigured between rounds.

## Persona Management

### Loading Personas

Read all `*.persona` files from the `personas/` directory. Parse as YAML.
See `references/persona-spec-format.md` for the full schema.

### Default Personas

The skill ships with 8 default personas in `personas/`. The user can:
- Add new personas by creating `.persona` files
- Remove personas by deleting files or setting `always_include: false`
- Edit personas by modifying the YAML
- Ask Claude to generate new personas for their specific context

### Generating Personas

When the user asks for a persona not in the collection, generate a new
`.persona` file following the schema. Ask the user to confirm before saving.

## File Layout

```
spec-review/
├── SKILL.md                          # This file
├── agents/
│   ├── persona-reviewer.md           # Sub-agent: individual persona review
│   ├── moa-synthesizer.md            # Sub-agent: MoA aggregation
│   └── spec-updater.md               # Sub-agent: applies decisions to spec
├── personas/
│   ├── gherkin-expert.persona
│   ├── ux-skeptic.persona
│   ├── software-engineer.persona
│   ├── cto.persona
│   ├── ceo-product.persona
│   ├── bdd-newcomer.persona
│   ├── compliance-audit.persona
│   └── qa-engineer.persona
├── references/
│   └── persona-spec-format.md        # PSF v1.0 schema reference
└── scripts/
    └── validate-personas.sh          # Validates persona YAML files
```

## Important Notes

- **Parallel execution is critical.** The entire value of this workflow depends on
  spawning persona reviewers in parallel. Sequential execution defeats the purpose.
- **Sub-agents get the full spec.** Each persona reviewer needs the complete spec
  to give contextual feedback. Don't summarize or truncate.
- **The synthesis agent is the most important agent.** It's the MoA aggregator.
  Its quality determines the quality of the consolidated output. Give it all
  persona reviews unabridged.
- **Interactive interview is human-in-the-loop.** Don't skip it. Don't auto-answer.
  The product owner's decisions are the ground truth.
- **Version the spec.** Always increment the version number when producing an
  updated spec. Never overwrite the original.
