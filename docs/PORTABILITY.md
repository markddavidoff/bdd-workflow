# Portability

What works away from Claude Code, and what does not. This narrows the "portable" claim to what was
actually verified, so you know what you get on a non-Claude agent or a skills-CLI-only install.

## Portable

- **The methodology.** The BDD-first workflow — feature specs agreed before code, Gherkin
  conventions, the propose → approve → implement sequence — is prose in `SKILL.md` files and carries
  to any agent that reads skills.
- **The knowledge base.** `bdd-knowledge-base` ships a pinned, sha256-verified release. Off Claude,
  populate it by hand (see the `bdd-kb` skill's "Manual (non-Claude) bootstrap") into `./.gherkin-kb`;
  the skill resolves `$GHERKIN_KB_PATH` → `${CLAUDE_PLUGIN_DATA}/kb` → `./.gherkin-kb`.
- **The `.bdd.json` schema.** `schemas/bdd-config.schema.json` is a plain JSON Schema; any tool can
  read a project's config.
- **`bdd-feature-sync`'s adversarial edge-case review.** Its fan-out uses the built-in
  `general-purpose` sub-agent, not a plugin-supplied one. On a skills-CLI-only install it still
  launches the parallel reviewers (POC 5, live-invoke: three `general-purpose` sub-agents returned
  edge cases with no `plugins/` present).

## Claude / plugin only

- **The multi-persona `spec-review` machinery.** It needs the `persona-reviewer` + MoA synthesis
  agents and the `.persona` files, all of which live under `plugins/`. A skills-CLI-only install
  ships **0 agents and 0 personas**, so `spec-review` blocks at Phase 1 without them (POC 5). Do not
  rely on the persona panel off Claude; it is a Claude/plugin-only differentiator.
- **The auto-fetch + trigger hooks.** The `SessionStart` KB fetch and the `UserPromptSubmit` BDD
  detection are Claude Code hooks. Off Claude they simply do not run — the KB is bootstrapped
  manually and triggering falls back to the `.bdd.json` gate below.

## Off-Claude triggering is fail-closed

`bdd-feature-sync` activates off Claude **only when `.bdd.json` is present**. In a plain repo (no
`.bdd.json`) it stays silent by construction — a file check, not a model choice. This is deliberate:
POC 6 showed that with no trigger hook, the skill's broad description makes the model self-fire on
natural feature-request phrasing even in a plain repo (both haiku and sonnet), then impose BDD. The
`.bdd.json` gate is the only reliable off-hook control. On Claude, the `SessionStart` trigger hook
may re-widen activation.

## Summary

| Capability | Skills-CLI / non-Claude | Claude + plugins |
|---|---|---|
| BDD methodology + Gherkin conventions | ✅ | ✅ |
| Knowledge base | ✅ (manual bootstrap) | ✅ (auto-fetch) |
| `bdd-feature-sync` adversarial review | ✅ (built-in `general-purpose`) | ✅ |
| `spec-review` persona panel | ❌ (0 agents / 0 personas) | ✅ |
| Triggering | fail-closed on `.bdd.json` | hook may re-widen |
