# Decision: Plugin Setup Approach

## Context

Need to install Codex plugin (for Claude Code) and Caveman plugin (for Claude Code and Codex) as part of the primer template.

## Options considered

### A. Add plugin install commands to existing setup-devcontainer.sh (rejected)

Inline all plugin commands directly in the post-create script.

- Simpler (one file), but mixes concerns (git hooks vs plugin setup).
- No way to re-run plugin setup independently.

### B. Separate setup-plugins.sh script + justfile target (chosen)

Extract plugin installation into its own script, call it from setup-devcontainer.sh, and expose it as `just setup-plugins`.

- Separation of concerns — each script has one job.
- Users can re-run plugin setup without rebuilding the container.
- Consistent with existing pattern (`setup-git.sh` + `just setup-git`).

### C. Use devcontainer postStartCommand or lifecycle hooks (rejected)

Configure plugins via devcontainer lifecycle events rather than a shell script.

- Harder to run manually outside the container.
- Less visible — buried in JSON config rather than explicit scripts.

## Decision

**Option B** — separate script with justfile target. Follows the existing setup-git pattern and keeps concerns cleanly separated.
