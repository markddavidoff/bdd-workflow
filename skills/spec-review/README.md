# spec-review — Multi-Persona Spec Review Skill

A Claude Code skill that reviews specification documents from multiple configurable
stakeholder perspectives using parallel sub-agents, synthesizes feedback using
Mixture-of-Agents (MoA) inspired aggregation, and drives interactive interviews
to produce improved specs.

## What It Does

1. **Parallel Persona Review** — Spawns up to 10 concurrent sub-agents, each
   adopting a different stakeholder persona to review your spec independently
2. **MoA Synthesis** — An aggregation agent consolidates all reviews, identifies
   consensus, preserves conflicts as decision points, and generates interview questions
3. **Interactive Interview** — Walks you through prioritized questions to resolve
   gaps and make product decisions
4. **Spec Update** — Produces an improved version of your spec incorporating all decisions

## Installation

### Claude Code (Project-Level)

```bash
# From your project root:
cp -r spec-review/ .claude/skills/spec-review/

# Copy the sub-agents:
cp spec-review/agents/*.md .claude/agents/
```

### Claude Code (User-Level — Available Across Projects)

```bash
cp -r spec-review/ ~/.claude/skills/spec-review/
cp spec-review/agents/*.md ~/.claude/agents/
```

### Verify

```bash
# Validate persona files
bash .claude/skills/spec-review/scripts/validate-personas.sh \
  .claude/skills/spec-review/personas/
```

## Usage

### Basic Usage

```
Review my spec from multiple stakeholder perspectives:
[paste spec or point to file]
```

Claude will automatically:
1. Load all personas from `personas/`
2. Fan out parallel sub-agent reviews
3. Run MoA synthesis
4. Start the interactive interview
5. Produce an updated spec

### Customize Personas

**Add a persona:**
```
Create a new persona for a "Data Privacy Officer" focused on GDPR compliance
```
Claude will generate a `.persona` file and ask you to confirm.

**Edit a persona:**
Open any `.persona` file and modify the YAML. The format is documented in
`references/persona-spec-format.md`.

**Remove a persona:**
Delete the `.persona` file, or set `always_include: false`.

### Targeted Review

```
Review my spec using only the engineering personas (software-engineer, cto, qa-engineer)
```

### Re-review After Changes

```
Run another review round on the updated spec with the same personas
```

## Persona Specification Format (PSF)

Personas are defined in `.persona` files using a YAML format inspired by
CrewAI's agent definitions. See `references/persona-spec-format.md` for the
full schema.

**Minimal example:**
```yaml
id: data-privacy-officer
name: "Data Privacy Officer"
role: "DPO responsible for GDPR/CCPA compliance across all products"
goal: "Ensure the spec handles PII correctly, has retention policies, and meets regulatory requirements"
backstory: "You've been a DPO for 6 years across fintech and HR-tech companies."
```

**Key fields from CrewAI:**
- `role` → identity frame (who you are)
- `goal` → what you're trying to achieve in the review
- `backstory` → experience and worldview that shapes your perspective

**Extended fields for review personas:**
- `focus_areas` → what you zoom in on
- `concerns` → your typical worries
- `style` → tone, detail level, and stance
- `weight` → influence in MoA synthesis

## Architecture

```
Orchestrator (SKILL.md)
  │
  ├─► persona-reviewer (×N parallel sub-agents)
  │     Each adopts one persona, reviews the full spec
  │     Writes to reviews/{persona-id}-review.md
  │
  ├─► persona-moa-synthesis (skill: persona framing) ─► moa-synthesizer (generic agent)
  │     Maps each review to a weighted source, then the generic agent
  │     does MoA-inspired aggregation → consolidated report + interview questions
  │     Writes to reviews/synthesis.md
  │
  ├─► Interactive Interview (human-in-the-loop)
  │     Product owner answers questions
  │     Writes to reviews/decisions.md
  │
  └─► spec-updater (1 agent)
        Applies decisions to produce improved spec
        Writes to {spec-name}-v{N+1}.md
```

## Default Personas

| Persona | Stance | Weight | Focus |
|---------|--------|--------|-------|
| Gherkin Expert | Skeptical | 1.0 | Scenario quality, declarative-vs-imperative, catalogs |
| UX Skeptic | Skeptical | 0.8 | Usability, first-run, accessibility, mobile |
| Software Engineer | Skeptical | 1.0 | Architecture, data models, security, feasibility |
| CTO | Neutral | 0.9 | Scalability, compliance, vendor strategy |
| CEO (Product) | Skeptical | 0.9 | Pricing, differentiation, onboarding, GTM |
| BDD Newcomer | Neutral | 0.8 | Onboarding, jargon, learnability |
| Compliance / Audit | Skeptical | 0.7 | Traceability, audit trail, data integrity |
| QA Engineer | Skeptical | 1.0 | State machines, edge cases, testability |

## File Structure

```
spec-review/
├── SKILL.md                          # Orchestrator instructions
├── README.md                         # This file
├── agents/
│   ├── persona-reviewer.md           # Sub-agent: individual review
│   ├── moa-synthesizer.md            # Sub-agent: MoA aggregation
│   └── spec-updater.md               # Sub-agent: applies decisions
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
│   └── persona-spec-format.md        # PSF v1.0 schema
└── scripts/
    └── validate-personas.sh          # Persona YAML validator
```

## License

MIT
