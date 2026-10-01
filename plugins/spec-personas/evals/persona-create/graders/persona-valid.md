---
type: llm
focus:
  source: file
  path: personas/security-reviewer.persona
---

PASS if the file reads as a coherent security-reviewer persona: it names security-specific review
concerns (e.g. authentication/authorization, input validation, secret handling, data exposure).
FAIL if it is empty, a generic placeholder, or not focused on security review.
