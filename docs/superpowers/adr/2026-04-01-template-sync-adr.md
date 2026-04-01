## ADR-001: Sync Mechanism

- **Date:** 2026-04-01
- **Status:** accepted

### Context
Need to keep `.claude/` configuration in sync across multiple projects from a central template.

### Options Considered
- **Git subtree** — built into git, local overrides handled via merge, no extra tooling. Verbose commands but reliable.
- **Sync script** — shell script that copies files, needs custom override detection logic. Full control but another tool to maintain.
- **GitHub Action** — reusable action on consumer repos that fetches and opens PRs. Automated but more infrastructure, harder to debug.

### Decision
Git subtree. It uses git's own merge machinery for conflict resolution (local wins naturally), requires zero extra tooling, and is well-understood.

### Consequences
Subtree commands are verbose but reliable. No external dependencies. Merge conflicts surface naturally through git.

## ADR-002: Source of Truth Architecture

- **Date:** 2026-04-01
- **Status:** accepted

### Context
Deciding where `.claude/` content lives as the source of truth and how changes flow between the template repo and consumers.

### Options Considered
- **Dedicated branch in template repo** — a `sync` branch containing only `.claude/` content. Requires automation to keep branch in sync with main. One repo but complex.
- **Separate repo as hub** — a standalone repo (`dotclaude`) containing `.claude/` at its root. Template subtrees it in, develops rules, pushes back. Consumers pull from the hub. Clean separation.
- **Template repo as direct source** — consumers subtree from template repo. Circular dependency if template also needs to consume. Doesn't work.

### Decision
Separate repo (`dotclaude`) as the hub. The template repo subtrees it in and pushes changes back. All consumers (including template) are subtree consumers of `dotclaude`.

### Consequences
No circular dependencies. Clean separation of concerns. The `dotclaude` repo is single-purpose. `git subtree push` from template keeps the hub updated.

## ADR-003: Sync Scope

- **Date:** 2026-04-01
- **Status:** accepted

### Context
Deciding what content to sync across projects.

### Options Considered
- **`.claude/` only** — rules, settings, skills, agents, commands. The shared configuration that applies everywhere.
- **`.claude/` + `docs/superpowers/`** — also sync ADRs, specs, and plans. But these are project-specific outputs from brainstorming, not shared config.

### Decision
Sync `.claude/` only. `docs/superpowers/` stays project-local since it contains project-specific design decisions and plans.

### Consequences
Each project generates its own specs, plans, and ADRs. Only the Claude Code configuration is shared.

## ADR-004: Update Notification Mechanism

- **Date:** 2026-04-01
- **Status:** accepted

### Context
Deciding how consumer repos learn about and receive template updates.

### Options Considered
- **Manual on-demand** — user runs a command when they want to sync. Simple but easy to forget.
- **Notify only** — session start hook checks for updates and tells user to sync. Low risk but requires manual action.
- **Auto-pull with summary** — session start hook fetches, pulls, and shows what changed. Aborts on conflicts. Fully automated with visibility.

### Decision
Auto-pull with summary via a Claude Code session start hook. On conflict, abort and notify the user to resolve manually.

### Consequences
Updates land automatically at session start. Users see what changed. Conflicts require manual intervention, which is the correct behavior for local overrides.
