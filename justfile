# Show available tasks
default:
	@just --list

# Run interactive GitHub auth + SSH signing setup
setup-git:
	./scripts/setup-git.sh

# Launch Claude Code with all permissions
claude:
	claude --dangerously-skip-permissions

# Install/update AI agent plugins
setup-plugins:
	./scripts/setup-plugins.sh

# Sync template from upstream
sync-template:
	./scripts/sync-template.sh
