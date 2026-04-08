# Agents

- ALWAYS work in git worktrees on feature branches.
- ALWAYS open a draft PR when starting work.
- ALWAYS save plans as YYYY-MM-DD-feature-slug-plan.md in /docs/plans/.
- ALWAYS commit and push the plan before starting any implementation work.
- ALWAYS save decisions as YYYY-MM-DD-feature-slug-decision.md in /docs/decisions/ when choosing between alternatives, including what was chosen, what was rejected, and why.
- ALWAYS capture decisions before implementing the chosen approach — if you picked one option over another, write the decision file first.
- ALWAYS prefer functional programming with small, pure functions.
- ALWAYS write a failing test first, implement until it passes, then commit.
- ALWAYS use conventional commits with scope.
- ALWAYS push after every commit.
- NEVER store memories in the global home directory (~/.claude/) — this is a sandbox/devcontainer and state is wiped on rebuild.
