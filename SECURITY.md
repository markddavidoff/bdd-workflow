# Security Policy

This is a personal, source-available project provided with **no warranty** (see [LICENSE](LICENSE)).
The plugins run shell commands on your machine — a knowledge-base fetch (a network download) and
cache cleanup (file removal) under the plugin's own data directory. Review the source before
installing.

## Reporting a vulnerability

If you find a security issue, please **do not open a public issue**. Report it privately by
opening a GitHub security advisory on this repository
(`https://github.com/markddavidoff/bdd-workflow` → **Security** → **Report a vulnerability**), or
by contacting the maintainer through the address on the GitHub profile.

Please include what the issue is, how to reproduce it, and the impact. There is no bounty and no
SLA (this is a personal project), but disclosures are taken seriously and will be acknowledged.

## Scope

In scope: the plugin skills, hooks, and scripts in this repository — the KB fetch path, file
removal, and any command that touches the network or filesystem. Out of scope: the security of
Claude Code itself, third-party knowledge-base sources, and anything outside this repository.
