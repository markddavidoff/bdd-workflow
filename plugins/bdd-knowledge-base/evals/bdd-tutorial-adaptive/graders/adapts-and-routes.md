---
type: llm
---

PASS only if ALL hold:
1. The response does NOT re-explain what BDD is (the user said they know it) — adaptivity honored.
2. It presents the walkthrough action menu (multiple choices including walking an example and
   generating artifacts for the user's project).
3. It actually tours the library-lending example — references the planted feature
   (`lending.feature` / the "borrows an available book" scenario) drawn from the scaffolded files.
4. It states the "analyze my whole project automatically" option is NOT yet available / coming
   soon (does not claim to have done it).
FAIL if it re-teaches BDD basics, skips the menu, invents example content not in the scaffold, or
claims the autonomous whole-project analysis is available/done.
