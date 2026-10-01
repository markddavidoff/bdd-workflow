# persona-manager — Interactive Persona Management Skill

A Claude Code skill for interactively creating, editing, cloning, validating,
and managing `.persona` files used by the `spec-review` skill.

## What It Does

Instead of hand-editing YAML, this skill walks you through persona management
conversationally:

- **Create** — Interview-style workflow that asks about the persona's role, goals,
  backstory, focus areas, concerns, and style, then generates a validated `.persona` file
- **Edit** — Modify specific fields of an existing persona with natural language
  ("make the engineer less skeptical", "add a concern about data privacy")
- **Clone** — Create a variant of an existing persona for a different context
- **Generate** — Bulk-generate a review panel from a domain description or spec
- **List** — See all personas with their key attributes at a glance
- **Validate** — Check all personas against the PSF v1.0 schema
- **Delete** — Remove a persona with confirmation
- **Import/Export** — Move personas between projects

## Installation

### Claude Code (Project-Level)

```bash
# Extract if from tarball
tar xzf persona-manager-skill.tar.gz

# From your project root:
cp -r persona-manager-skill/ .claude/skills/persona-manager/
cp persona-manager-skill/agents/*.md .claude/agents/
```

### Claude Code (User-Level)

```bash
cp -r persona-manager-skill/ ~/.claude/skills/persona-manager/
cp persona-manager-skill/agents/*.md ~/.claude/agents/
```

> **Note:** This skill works alongside `spec-review`. Both read from the
> same `personas/` directory. Install both for the full workflow.

## Usage Examples

### Create a Persona

```
Create a persona for a Data Privacy Officer
```

Claude will interview you step-by-step:
1. Role → "Who is this person?"
2. Goal → "What do they care about in a spec review?"
3. Backstory → "What's their professional background?"
4. Focus areas & concerns → "What do they zoom in on?"
5. Style → tone, detail level, stance (picks from options)
6. Tuning → always include? weight?
7. Review → shows the complete file for confirmation

### Edit a Persona

```
Make the QA engineer persona more thorough and add a concern about API rate limiting
```

Claude loads the file, shows what will change, applies edits, and re-validates.

### Quick Edits

```
Set the ux-skeptic persona weight to 0.9
Change the CTO's stance from neutral to skeptical
Add "regulatory compliance" to the compliance-audit persona's focus areas
```

### Clone a Persona

```
Clone the software-engineer persona as a frontend specialist
```

Creates a new persona with a different ID, name, and adjusted focus areas
while preserving the structure.

### Generate a Panel

```
Generate review personas for an e-commerce marketplace spec
```

Claude analyzes the domain and suggests 5-8 personas (e.g., buyer, seller,
marketplace ops, payments engineer, fraud analyst, customer support).
You pick which ones to create.

### List All Personas

```
Show me my current review panel
```

Displays a table with name, stance, weight, active status, and top focus areas.

### Validate

```
Validate all my personas
```

Runs the schema validator and reports any issues with fix suggestions.

## File Structure

```
persona-manager/
├── SKILL.md                          # Orchestrator instructions
├── README.md                         # This file
├── agents/
│   └── persona-generator.md          # Sub-agent: bulk persona generation
├── references/
│   └── persona-spec-format.md        # PSF v1.0 schema reference
└── scripts/
    └── validate-personas.sh          # Persona YAML validator
```

## Persona Specification Format (PSF) Quick Reference

```yaml
# Required
id: lowercase-hyphenated           # Must match filename
name: "Human Readable Name"
role: "One-line identity frame"
goal: "What they're trying to achieve in review"
backstory: "Professional context and worldview"

# Optional
focus_areas: [...]                 # What they zoom in on
concerns: [...]                    # Typical worries as questions
style:
  tone: direct|diplomatic|analytical|passionate
  detail: brief|moderate|thorough
  stance: supportive|neutral|skeptical|adversarial
knowledge: [...]                   # Domain expertise tags
always_include: true|false         # Auto-include in every review?
weight: 0.0-1.0                    # Influence in MoA synthesis
tags: [...]                        # Grouping/filtering
```

Full schema: `references/persona-spec-format.md`

## License

MIT
