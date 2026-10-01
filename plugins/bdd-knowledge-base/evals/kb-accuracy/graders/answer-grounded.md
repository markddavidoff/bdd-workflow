---
type: llm
---

PASS if the answer states BOTH facts from the knowledge base — (1) the required keyword for the
example table of a Scenario Outline is `Examples:` (not `Scenarios:`), and (2) the canonical maximum
is 7 columns — AND indicates it drew them from the knowledge base (cites/names the KB page or the
bdd-kb source).
FAIL if either fact is missing, wrong, or hedged, if the answer invents rules not in the knowledge
base, or if it does not ground the answer in the KB.
