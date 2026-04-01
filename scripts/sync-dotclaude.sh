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
