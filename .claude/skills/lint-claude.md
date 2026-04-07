---
name: lint-claude
description: Validates CLAUDE.md conventions when editing or creating it
autoTrigger: When editing or creating CLAUDE.md
---

When editing or creating CLAUDE.md, validate the following conventions:

1. **Line count:** Must be under 200 lines
2. **Constraint pattern:** Every constraint must follow "DON'T do x — DO y" pattern (both a negative and a positive)
3. **No misplaced rules:** No rules that belong in settings.json or hooks instead (like attribution, formatting, permissions)
4. **Necessity test:** Every rule should fail the test: "Would Claude actually get this wrong without it?" — flag any that would not

Output a pass/fail summary with specific line numbers for violations.
