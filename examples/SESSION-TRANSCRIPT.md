# A real Claude Code session

This is a lightly annotated transcript of an **actual** Claude Code session (model: Sonnet) with the
four plugins installed. It shows what the static files can't: the skill firing, the review agents
running, and the spec-first gate holding for approval. Nothing here is invented — it is the real
output of a run.

## Setup

The plugins were installed into a clean session, and the project already had a `.bdd.json` and a
starter `docs/features/auth.feature` with a single "Log in" scenario.

## The prompt

> First consult the bdd-kb knowledge base for Gherkin scenario-authoring best practices. Then add a
> "Password reset" scenario to `docs/features/auth.feature`. Then generate a test for the auth feature.

## What Claude Code did (tool by tool)

1. **Skill fired** — `bdd-flow:bdd-feature-sync` activated on its own (no manual invocation), because
   the project is BDD-configured.
2. **Adversarial review dispatched** — it ran three review agents in the background: **QA engineer**,
   **exploratory tester**, and **product manager**.
3. **It paused and reported:** *"I've kicked off the mandatory adversarial edge-case review… I'll fold
   their findings into a proposal once they return, then present it for your approval before editing
   `auth.feature` or writing tests — per this repo's BDD workflow, feature changes need explicit
   sign-off first."*

## The consolidated proposal it produced

The review turned one requested scenario into a core scenario **plus six edge cases the agents
surfaced** — and it explicitly dropped three as speculative:

```gherkin
# Proposal 1 — Password reset (core flow)
Scenario: Password reset
  Given a registered user has requested a password reset
  When they set a new password using the reset link
  Then they can log in with the new password

# Proposal 2 — Unregistered email doesn't reveal account existence   [account enumeration — QA]
Scenario: Requesting a reset for an unregistered email does not reveal account existence
  Given no account is registered with "unknown@example.com"
  When a password reset is requested for "unknown@example.com"
  Then a generic confirmation message is shown
  And no reset email is sent

# Proposal 3 — Expired reset link is rejected   [token validity — QA + PM]
# Proposal 4 — A reset link cannot be used twice   [single-use token — all three]
# Proposal 5 — Old password stops working after reset   [exploratory tester]
# Proposal 6 — Repeated reset requests are throttled   [rate-limiting — QA]
# Proposal 7 — New password must meet the password policy   [input validation — QA]
```

> **Dropped (with reasons):** the product-manager persona's "shared/public computer session hygiene,"
> "no access to registered email," and "cross-device link" scenarios — dropped because they depend on
> infrastructure this project doesn't have yet, so they'd be speculative rather than testable.

## The gate held

It then asked how to proceed — *Accept all 7 / Accept some / Revise / Reject / Add more* — and wrote
**nothing** until told to. Only after approval would it write the scenarios into `auth.feature` and
generate the tests.

That is the whole point of the workflow: one plain-language request becomes a reviewed,
edge-case-hardened spec, and **no code or spec is written until you sign off**.
