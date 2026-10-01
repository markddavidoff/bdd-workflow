---
description: Remove the cached BDD knowledge base from the plugin data directory.
---

Delete the plugin's KB cache so nothing downloaded remains on disk. Run:

Run `rm -rf "${CLAUDE_PLUGIN_DATA}/kb" "${CLAUDE_PLUGIN_DATA}/versions" "${CLAUDE_PLUGIN_DATA}/kb.installed.json" "${CLAUDE_PLUGIN_DATA}/kb.backoff"`
and confirm the cache is gone (`${CLAUDE_PLUGIN_DATA}/kb` no longer exists).

To also stop future auto-fetches, tell the user to set `GHERKIN_KB_DISABLE=1` in their environment;
otherwise the next `SessionStart` will re-fetch the pinned KB.
