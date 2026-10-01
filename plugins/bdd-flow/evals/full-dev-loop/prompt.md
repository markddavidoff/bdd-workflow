---
name: full-dev-loop
tags: [e2e, loop]
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---
You are operating autonomously with full pre-approval — do NOT pause for confirmation at any step.
Treat each spec you write as approved the moment you write it, and proceed immediately to the next
step. Build the "is-even" feature end to end and complete every step in this session:
1. Create a reviewer persona and save it to `personas/reviewer.persona`.
2. Write a Gherkin spec at `docs/features/is-even.feature` with scenarios for an even number, an
   odd number, and zero.
3. Generate a Node test file under `tests/` (using `node --test`) covering those scenarios.
4. Implement `isEven` in `src/is-even.js` so the tests pass.
5. Run the tests and save their full raw output to a file: `npm test > test-output.txt 2>&1`.
Do all five steps now without stopping for approval.
