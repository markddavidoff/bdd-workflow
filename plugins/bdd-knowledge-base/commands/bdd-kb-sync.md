---
description: Download or refresh the pinned BDD knowledge base into the plugin cache.
---

Run the KB sync script for this plugin, forcing a fetch even if a marker exists:

Run `bash "${CLAUDE_PLUGIN_ROOT}/scripts/sync-kb.sh" "${CLAUDE_PLUGIN_ROOT}" "${CLAUDE_PLUGIN_DATA}" --force`
and report whether the KB is now present at `${CLAUDE_PLUGIN_DATA}/kb`, including the
installed version from `${CLAUDE_PLUGIN_DATA}/kb.installed.json`.
