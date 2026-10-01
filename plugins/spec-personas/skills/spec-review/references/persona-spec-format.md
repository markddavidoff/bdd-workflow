# Persona Specification Format (PSF) v1.0

**A human-readable, machine-parseable format for defining review personas.**

Inspired by CrewAI's `role`/`goal`/`backstory` YAML agent definitions, ElizaOS's
characterfile arrays, and Gherkin's philosophy of bridging humans and machines.

## File Convention

- **Extension:** `.persona`
- **Format:** YAML document
- **Location:** `personas/` directory relative to the skill or project root
- **Encoding:** UTF-8

## Schema

```yaml
# ─── REQUIRED FIELDS ────────────────────────────────────────────────

# Unique identifier for this persona (lowercase, hyphens)
id: security-reviewer

# Human-readable display name
name: "Security Reviewer"

# One-line role description — used by the orchestrator to decide
# when this persona is relevant and as the opening identity frame
# for the sub-agent. Equivalent to CrewAI's `role` field.
role: >
  An application security engineer who reviews specs for
  authentication, authorization, and data-handling risks.

# What this persona is trying to achieve when reviewing a document.
# Drives the persona's priorities, what they focus on, and what they
# push back on. Equivalent to CrewAI's `goal` field.
goal: >
  Ensure the spec closes obvious attack surface — unauthenticated
  endpoints, unbounded input, secrets in logs — without blocking
  delivery on theoretical risks.

# The persona's professional context, experience, and worldview.
# Provides the LLM with grounding for realistic, nuanced feedback.
# Equivalent to CrewAI's `backstory` field.
backstory: >
  You've spent 12 years in application security across SaaS and
  e-commerce. You've seen too many features ship with the auth check
  in the UI but not the API, and you read a spec for the boundary
  that was assumed rather than stated.

# ─── OPTIONAL FIELDS ────────────────────────────────────────────────

# Key areas this persona focuses on when reviewing.
# The orchestrator uses these to generate targeted review prompts.
# Array of short strings.
focus_areas:
  - authentication and authorization boundaries
  - input validation and injection surface
  - secrets handling and logging hygiene
  - data exposure in API responses

# Typical concerns, pain points, or biases this persona carries.
# Helps the LLM generate realistic pushback and edge case questions.
concerns:
  - "Is this endpoint authorized on the server, not just hidden in the UI?"
  - "What happens when the input is 10x larger than expected?"
  - "Could this log line leak a token or PII?"

# Tone and communication style modifiers.
# Adjusts how the persona frames its feedback.
style:
  tone: analytical      # direct | diplomatic | analytical | passionate
  detail: thorough      # brief | moderate | thorough
  stance: skeptical     # supportive | neutral | skeptical | adversarial

# Domain knowledge tags — used by the orchestrator to match
# personas to relevant features in the spec.
knowledge:
  - application security
  - authentication and authorization
  - input validation
  - secure logging

# When set to true, this persona is included in every review.
# When false, the orchestrator includes it only when relevant.
always_include: false

# Weight for this persona's feedback during synthesis (0.0 - 1.0).
# Higher weight = more influence on the consolidated output.
# Default is equal weight across all personas.
weight: 1.0

# Tags for filtering/grouping personas in collections.
tags:
  - stakeholder
  - security
  - technical
```

## Field Reference

### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique identifier. Lowercase, hyphens. Used as filename stem and sub-agent name. |
| `name` | string | Human-readable display name. Used in reports and consolidated output. |
| `role` | string | One-line identity frame. Injected as the persona's opening identity in the sub-agent prompt. |
| `goal` | string | What this persona is trying to achieve. Drives review priorities. |
| `backstory` | string | Professional context and experience. Grounds the LLM in a realistic worldview. |

### Optional Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `focus_areas` | string[] | `[]` | Key review focus areas. Used to generate targeted review prompts. |
| `concerns` | string[] | `[]` | Typical worries or pain points. Helps generate realistic pushback. |
| `style.tone` | enum | `direct` | Communication tone: `direct`, `diplomatic`, `analytical`, `passionate` |
| `style.detail` | enum | `moderate` | Feedback depth: `brief`, `moderate`, `thorough` |
| `style.stance` | enum | `neutral` | Default posture toward the spec: `supportive`, `neutral`, `skeptical`, `adversarial` |
| `knowledge` | string[] | `[]` | Domain knowledge tags for feature-matching. |
| `always_include` | boolean | `true` | Whether to include in every review regardless of relevance. |
| `weight` | float | `1.0` | Influence weight during MoA synthesis (0.0–1.0). |
| `tags` | string[] | `[]` | Grouping/filtering tags. |

## Design Principles

1. **Human-first readability.** A product manager, engineer, or designer should be able to read and edit a `.persona` file without technical help. YAML was chosen over JSON for this reason.

2. **Machine-parseable.** Standard YAML parsing. No custom grammar, no regex-dependent fields. Any YAML parser in any language can read it.

3. **CrewAI-compatible core.** The `role`, `goal`, and `backstory` fields map directly to CrewAI's agent definition, making it possible to reuse `.persona` files in CrewAI workflows or convert between formats.

4. **Extensible.** Unknown fields are ignored by the orchestrator. Teams can add custom fields (e.g., `department`, `seniority`, `avatar_url`) without breaking compatibility.

5. **Composable.** Multiple `.persona` files in a directory form a review panel. The orchestrator loads all `*.persona` files and fans them out as parallel sub-agents.

## Example: Minimal Persona

```yaml
id: ux-designer
name: "UX Designer"
role: "A product designer focused on clarity, accessibility, and first-run experience"
goal: "Ensure the spec's flows are usable, accessible, and unambiguous for real users"
backstory: "You've designed consumer and B2B products for 8 years and care about the empty state as much as the happy path."
```

## Example: Full Persona

```yaml
id: qa-engineer
name: "QA Engineer"
role: >
  A senior QA engineer responsible for test planning, automation,
  and quality assurance across the platform.
goal: >
  Ensure every feature is testable, edge cases are covered, state
  machines are explicit, and acceptance criteria are unambiguous.
backstory: >
  You've been in QA for 10 years, working on SaaS platforms with
  complex async workflows, calendar integrations, and email delivery.
  You've seen too many specs go to engineering without clear error
  states, and you've learned that the best time to find bugs is
  before code is written.
focus_areas:
  - state machine completeness
  - error and edge case coverage
  - testability of acceptance criteria
  - data integrity and race conditions
  - security testing gaps
concerns:
  - "Are all state transitions documented?"
  - "What happens in concurrent editing scenarios?"
  - "Where are the performance benchmarks?"
  - "Is there a test data strategy?"
style:
  tone: analytical
  detail: thorough
  stance: skeptical
knowledge:
  - test automation
  - state machines
  - API testing
  - email deliverability
  - security testing
always_include: true
weight: 1.0
tags:
  - engineering
  - quality
  - technical
```

## Validation Rules

1. `id` must match the pattern `^[a-z][a-z0-9-]*$` (lowercase, hyphens, starts with letter)
2. `id` must be unique within a persona collection
3. `role`, `goal`, and `backstory` must each be non-empty strings
4. `style.tone` must be one of: `direct`, `diplomatic`, `analytical`, `passionate`
5. `style.detail` must be one of: `brief`, `moderate`, `thorough`
6. `style.stance` must be one of: `supportive`, `neutral`, `skeptical`, `adversarial`
7. `weight` must be a float between 0.0 and 1.0 inclusive
8. File extension must be `.persona`
9. File must be valid YAML

## Converting From/To Other Formats

### To CrewAI YAML

```yaml
# .persona → CrewAI agents.yaml
<id>:
  role: <role>
  goal: <goal>
  backstory: <backstory>
```

### From CrewAI YAML

Add `id`, `name`, and optionally `focus_areas`, `concerns`, `style`, `knowledge`.

### To ElizaOS Characterfile

```json
{
  "name": "<name>",
  "bio": ["<role>"],
  "lore": ["<backstory>"],
  "style": { "all": ["<style.tone>", "<style.detail>"] },
  "topics": "<knowledge>",
  "adjectives": ["<concerns extracted as adjectives>"]
}
