# Template Sync via Git Subtree - Design Spec

## Goal

Enable syncing of `.claude/` configuration across all projects using a shared `dotclaude` repo as a hub, with git subtree as the transport mechanism.

## Components

### 1. `dotclaude` repo

A standalone GitHub repo (`mattiasthalen/dotclaude`) containing the `.claude/` content at its root:

```
dotclaude/
  rules/
  settings.json
  skills/
  agents/
  commands/
```

This is the shared hub. All consumers (including `claude-template`) pull from here.

### 2. `claude-template` repo (this repo)

Subtrees `dotclaude` into `.claude/`. This is where rules are authored and developed. Changes are pushed back to `dotclaude` via `git subtree push`.

### 3. Consumer repos

Any project that wants shared Claude config subtree-pulls from `dotclaude` into `.claude/`. Local overrides win on merge conflicts.

### 4. Session start hook

Every repo with the subtree (including this template) gets a Claude Code session start hook that:

1. Fetches the `dotclaude` remote
2. Checks for new commits
3. If updates exist, runs `git subtree pull` and shows what changed
4. If merge conflicts occur, aborts the merge and notifies the user

## Sync Flow

```
claude-template  --subtree push-->  dotclaude  <--subtree pull--  consumer repos
    (author)                         (hub)                        (consumers)
```

## Scope

- `.claude/` directory is synced via `dotclaude`
- `docs/superpowers/` stays project-local, not synced
- Local overrides in consumer repos win on merge conflicts

## Setup for a new consumer repo

```bash
git remote add dotclaude git@github.com:mattiasthalen/dotclaude.git
git subtree add --prefix=.claude dotclaude main
```
