---
name: persona-manager
description: >
  Interactively create, edit, clone, list, validate, and delete .persona files
  used by the spec-review skill. Use this skill whenever the user wants to
  manage review personas — including "create a persona", "add a persona",
  "edit the qa-engineer persona", "show me my personas", "delete a persona",
  "clone a persona", "generate personas for my project", "customize the
  review panel", or any variation of persona management. Also use when the
  user says things like "I need a security reviewer", "add a DPO perspective",
  or "make the engineer persona less skeptical".
---

# Persona Manager

An interactive skill for managing `.persona` files that define stakeholder
review perspectives for the `spec-review` skill. Supports the full CRUD
lifecycle plus generation, cloning, and bulk operations.

## Persona File Location

Personas live in one of these directories (check in order):

1. `.claude/skills/spec-review/personas/` (project-level)
2. `~/.claude/skills/spec-review/personas/` (user-level)
3. A custom path if the user specifies one

If no personas directory exists, ask the user where to create one.

## Commands

### List Personas

When the user asks to see their personas, list all, or show the review panel:

1. Glob for `*.persona` in the personas directory
2. Parse each file's YAML to extract `id`, `name`, `role`, `style.stance`, `weight`, `always_include`
3. Present as a table:

```
| # | Name                   | Stance    | Weight | Active | Focus Areas (top 2)         |
|---|------------------------|-----------|--------|--------|-----------------------------|
| 1 | Gherkin Expert         | skeptical | 1.0    | ✓      | scenario quality, catalogs   |
| 2 | QA Engineer            | skeptical | 1.0    | ✓      | state machines, edge cases   |
| ...                                                                                     |
```

### Create a Persona (Interactive)

Walk the user through creating a new persona conversationally. Don't dump a
blank template — interview them.

**Step 1: Identity**
Ask: "Who is this persona? Give me a job title or role description."
From the answer, draft the `name` and `role` fields.

**Step 2: Goal**
Ask: "When this persona reviews a spec, what are they trying to achieve?
What outcome matters most to them?"
Draft the `goal` field.

**Step 3: Backstory**
Ask: "What's their professional background? How many years of experience,
what have they seen go wrong, what makes them tick?"
Draft the `backstory` field.

**Step 4: Focus & Concerns**
Ask: "What specific things does this persona zoom in on when reviewing?
What are their typical worries or pet peeves?"
Draft `focus_areas` and `concerns`.

**Step 5: Style**
Present options:

- **Tone:** direct, diplomatic, analytical, passionate
- **Detail level:** brief, moderate, thorough
- **Default stance:** supportive, neutral, skeptical, adversarial

Let the user pick or suggest based on the persona's character.

**Step 6: Tuning**
Ask: "Should this persona always be included in reviews, or only when relevant?
How much weight should their feedback carry (0.0–1.0)?"

**Step 7: Review & Save**
Show the complete `.persona` file and ask the user to confirm. Generate the
`id` from the name (lowercase, hyphenated). Save to the personas directory.
Validate with the validation script.

### Edit a Persona

When the user wants to modify an existing persona:

1. If they name a specific persona, load that file
2. If they're vague ("make the engineer less harsh"), fuzzy-match to find it
3. Show the current content of the field(s) they want to change
4. Ask what the new value should be — or suggest a revision and confirm
5. Write the updated file
6. Re-validate

**Common edit patterns:**
- "Make X more skeptical" → change `style.stance`
- "The CTO should focus more on compliance" → update `focus_areas`
- "Give the ux-skeptic persona more weight" → update `weight`
- "The backstory is too generic" → rewrite `backstory` interactively
- "Add a concern about data privacy" → append to `concerns`

### Clone a Persona

When the user wants a variant of an existing persona:

1. Load the source persona
2. Ask what should change (at minimum, `id` and `name` must differ)
3. Create a new file with the modifications
4. Validate

Example: "Clone the software-engineer persona but make it a frontend specialist"

### Generate Personas from Context

When the user says something like "generate personas for my project" or
"suggest reviewers for this spec":

1. If a spec file is available, read it to understand the domain
2. Suggest 5-8 personas relevant to the spec's domain
3. Present them as a checklist — user picks which to create
4. For each selected persona, generate a complete `.persona` file
5. Show all generated files for confirmation before saving

Use the `persona-generator` sub-agent for bulk generation.

### Delete a Persona

1. Confirm which persona to delete (show the file content first)
2. Ask for explicit confirmation: "Delete ux-skeptic.persona? This cannot be undone."
3. Remove the file

### Validate All Personas

Run the validation script and report results:

```bash
bash scripts/validate-personas.sh <personas_dir>
```

Report any errors with clear fix instructions.

### Import / Export

**Export:** Copy a persona file to a user-specified path or print it to stdout.

**Import:** Accept a `.persona` file path or pasted YAML, validate it, and
copy to the personas directory.

## Sub-Agent: Persona Generator

For bulk persona generation, use the `persona-generator` sub-agent. It receives
a domain description (or a spec excerpt) and generates multiple `.persona`
files in one pass. The orchestrator then presents them to the user for
approval.

## Schema Reference

The full Persona Specification Format (PSF) v1.0 is documented in:
`references/persona-spec-format.md`

When generating or validating personas, always check this reference for
valid enum values, required fields, and formatting rules.

## Important Notes

- **Always validate after creating or editing.** Run the validation script
  to catch schema violations before they surface during a review.
- **IDs must match filenames.** The `id` field must equal the filename
  (minus `.persona`). If you rename a file, update the `id` field too.
- **Don't overwrite without confirmation.** Always show the user what will
  change and get explicit confirmation before writing.
- **Suggest, don't dictate.** When generating backstories or concerns, draft
  them and ask the user to refine. The user knows their stakeholders better
  than you do.
