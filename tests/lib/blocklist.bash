# Shared loader for the PRIVATE proprietary-vocab blocklist. The literal codenames/fingerprints live
# only in scripts/.domain-blocklist (gitignored), so the public repo never enumerates the private
# project names. When the file is absent (e.g. public CI), callers skip the proprietary-vocab checks
# — post-publish there is nothing private to catch; the checks guard the pre-publish workflow.
bl_file() { echo "${DOMAIN_BLOCKLIST_FILE:-scripts/.domain-blocklist}"; }
bl_present() { [ -f "$(bl_file)" ]; }
bl_pattern() { tr -d '\n' < "$(bl_file)"; }                       # full alternation regex
bl_first_token() { bl_pattern | cut -d'|' -f1; }                 # a known-bad token for probes
