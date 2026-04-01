# Template Sync Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Set up `dotclaude` as a shared hub repo and configure `claude-template` to sync `.claude/` via git subtree, with a session start hook that auto-pulls updates.

**Architecture:** `dotclaude` repo holds `.claude/` content at its root. `claude-template` (and future consumer repos) subtree-pull from it. A session start hook auto-syncs on every Claude Code session.

**Tech Stack:** Git subtree, GitHub CLI (`gh`), Bash (hook script), Claude Code hooks (`.claude/settings.json`)

---

### Task 1: Create the `dotclaude` repo on GitHub

**Step 1: Create the repo**

```bash
gh repo create mattiasthalen/dotclaude --public --description "Shared Claude Code configuration (.claude/ content)" --clone=false
```

**Step 2: Configure the repo**

```bash
# Enable auto-delete of merged branches
gh api repos/mattiasthalen/dotclaude -X PATCH -f delete_branch_on_merge=true

# Enable auto-merge
gh api repos/mattiasthalen/dotclaude -X PATCH -f allow_auto_merge=true
```

**Step 3: Verify**

```bash
gh repo view mattiasthalen/dotclaude --json name,description
```

Expected: repo exists with correct description.

**Step 4: Commit** — nothing to commit (remote-only operation).

### Task 2: Seed `dotclaude` repo with current `.claude/` content

This task works from a temporary clone, NOT the worktree.

**Step 1: Clone the empty repo**

```bash
cd $TMPDIR
git clone git@github.com:mattiasthalen/dotclaude.git
cd dotclaude
```

**Step 2: Copy `.claude/` content (at root, not nested)**

Copy the contents of `.claude/` from `claude-template` into the root of `dotclaude`:

```
dotclaude/
  rules/
    adr.md
    conventional-commits.md
    git-workflow.md
    repo-setup.md
    rule-style.md
    superpowers.md
  settings.json
  skills/.gitkeep
  agents/.gitkeep
  commands/.gitkeep
```

Do NOT copy `settings.local.json` (that's project-specific).

**Step 3: Configure git email**

```bash
git config --local user.email "$(git -C /home/mattiasthalen/repos/claude-template config --local user.email)"
```

**Step 4: Commit and push**

```bash
git add -A
git commit -m "feat: seed dotclaude with initial .claude/ content

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
git push
```

**Step 5: Verify**

```bash
gh repo view mattiasthalen/dotclaude --json name
ls -la
```

Expected: all rule files present at root of repo.

### Task 3: Set up subtree relationship in `claude-template`

Work from: `/home/mattiasthalen/repos/claude-template/.worktrees/feat/template-sync`

This is the trickiest task. `.claude/` already exists with content. We need to replace it with a subtree from `dotclaude` while preserving history.

**Step 1: Add `dotclaude` as a remote**

```bash
git remote add dotclaude git@github.com:mattiasthalen/dotclaude.git
git fetch dotclaude
```

**Step 2: Remove existing `.claude/` directory**

```bash
git rm -r .claude
git commit -m "refactor: remove .claude/ in preparation for subtree

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
```

**Step 3: Add `.claude/` back as a subtree**

```bash
git subtree add --prefix=.claude dotclaude main
```

**Step 4: Verify**

```bash
ls .claude/rules/
git log --oneline -3
```

Expected: all rule files present, commit history shows the subtree add.

**Step 5: Push**

```bash
git push
```

### Task 4: Create the sync hook script

Work from: `/home/mattiasthalen/repos/claude-template/.worktrees/feat/template-sync`

**Step 1: Create `scripts/sync-dotclaude.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail

# Check if dotclaude remote exists
if ! git remote get-url dotclaude &>/dev/null; then
  echo "dotclaude remote not configured. Skipping sync."
  echo "To set up: git remote add dotclaude git@github.com:mattiasthalen/dotclaude.git"
  exit 0
fi

# Fetch latest from dotclaude
git fetch dotclaude main --quiet 2>/dev/null || {
  echo "Failed to fetch dotclaude remote. Skipping sync."
  exit 0
}

# Check if there are new commits
LOCAL_TREE=$(git ls-tree HEAD .claude | awk '{print $3}')
REMOTE_TREE=$(git ls-tree dotclaude/main | head -1 | awk '{print $3}')

if [ "$LOCAL_TREE" = "$REMOTE_TREE" ]; then
  exit 0
fi

echo "=== dotclaude updates available ==="

# Show what changed
git diff HEAD...dotclaude/main --stat -- . | sed 's/^/  /'

# Attempt subtree pull
if git subtree pull --prefix=.claude dotclaude main --message "chore: sync .claude/ from dotclaude"; then
  echo ""
  echo "=== dotclaude sync complete ==="
  git diff HEAD~1 --stat -- .claude/ | sed 's/^/  /'
else
  echo ""
  echo "=== dotclaude sync failed (merge conflict) ==="
  echo "Aborting merge. Resolve manually with:"
  echo "  git subtree pull --prefix=.claude dotclaude main"
  git merge --abort 2>/dev/null || true
fi
```

**Step 2: Make executable**

```bash
chmod +x scripts/sync-dotclaude.sh
```

**Step 3: Verify script is syntactically valid**

```bash
bash -n scripts/sync-dotclaude.sh
```

Expected: no output (no syntax errors).

**Step 4: Commit**

```bash
git add scripts/sync-dotclaude.sh
git commit -m "feat: add dotclaude sync hook script

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
```

**Step 5: Push**

```bash
git push
```

### Task 5: Add session start hook to settings.json

Work from: `/home/mattiasthalen/repos/claude-template/.worktrees/feat/template-sync`

**Step 1: Read current `.claude/settings.json`**

Check current contents to know what to modify.

**Step 2: Add the hook configuration**

Add a `hooks` section to `.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "superpowers@claude-plugins-official": true
  },
  "hooks": {
    "SessionStart": [
      {
        "type": "command",
        "command": "bash scripts/sync-dotclaude.sh"
      }
    ]
  }
}
```

**Step 3: Verify JSON is valid**

```bash
python3 -c "import json; json.load(open('.claude/settings.json'))"
```

Expected: no output (valid JSON).

**Step 4: Commit**

```bash
git add .claude/settings.json
git commit -m "feat: add session start hook for dotclaude sync

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
```

**Step 5: Push subtree changes back to dotclaude**

Since we modified `.claude/settings.json` (which is the subtree), push changes back:

```bash
git subtree push --prefix=.claude dotclaude main
```

**Step 6: Push template branch**

```bash
git push
```

### Task 6: Open draft PR

**Step 1: Create draft PR**

```bash
gh pr create --draft --title "feat: add dotclaude subtree sync with session start hook" --body "$(cat <<'EOF'
## Summary
- Creates `dotclaude` repo as shared hub for `.claude/` configuration
- Sets up git subtree relationship in `claude-template`
- Adds `scripts/sync-dotclaude.sh` hook that auto-pulls updates on session start
- Configures Claude Code session start hook in `.claude/settings.json`

## Sync flow
```
claude-template  --subtree push-->  dotclaude  <--subtree pull--  consumer repos
    (author)                         (hub)                        (consumers)
```

## Setup for new consumer repos
```bash
git remote add dotclaude git@github.com:mattiasthalen/dotclaude.git
git subtree add --prefix=.claude dotclaude main
cp scripts/sync-dotclaude.sh scripts/  # if not already present
```

## Test plan
- [ ] Verify `dotclaude` repo exists with correct content
- [ ] Verify `.claude/` in template is a working subtree
- [ ] Verify `git subtree pull --prefix=.claude dotclaude main` works
- [ ] Verify `git subtree push --prefix=.claude dotclaude main` works
- [ ] Verify sync hook runs on session start
- [ ] Verify hook handles missing remote gracefully
- [ ] Verify hook handles merge conflicts gracefully

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```
