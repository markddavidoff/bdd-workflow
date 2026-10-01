---
type: llm
---

The user's message was a bare, answerless invocation of the tutorial (no context, no choices given).
PASS if the response does a reasonable answerless thing: it presents an overview and/or the
walkthrough options and either asks the user what they know / which option they want, OR gives the
static overview and points to running it interactively.
FAIL if the response FABRICATES the user's answers or choices on their behalf (e.g. assumes they
picked an option and executes it), or claims to have analyzed/generated artifacts for the user's
project without being asked, or claims the autonomous whole-project analysis is available/done.
