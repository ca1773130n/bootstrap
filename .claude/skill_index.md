# Skill Index

Optional Claude Code skills are available in `extras/claude-skills/`.

To enable skills:
1. Copy desired skill files from `extras/claude-skills/` to `.claude/skills/`
2. Invoke with: `Apply <skill_name> skill to <target_path>`

## Available Skills (in extras/)

| Skill | Purpose |
|-------|---------|
| `smart_commit` | Auto-group changes, atomic commits |
| `repo_gardening` | Repository hygiene, file organization |
| `doc_sync` | Keep docs in sync with code |
| `refactor_safe` | Safe internal refactoring (80% coverage required) |
| `ci_fix` | Auto-fix CI failures |
| `api_evolution_safe` | Evolve APIs without breaking clients |
| `vue_perf_tune` | Vue 3 + Vite performance optimization |
