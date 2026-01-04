# Skill Index

Skills are available for AI agents in two locations:

## OpenCode Skills (`.opencode/skill/`)

Primary location for oh-my-opencode skill discovery:

| Skill | Path | Purpose |
|-------|------|---------|
| `refactor-safe` | `.opencode/skill/refactor-safe/` | Pre-commit code simplification |
| `api-evolution-safe` | `.opencode/skill/api-evolution-safe/` | Evolve APIs without breaking clients |
| `ci-fix` | `.opencode/skill/ci-fix/` | Fix CI failures without masking issues |
| `doc-sync` | `.opencode/skill/doc-sync/` | Keep docs in sync with code |
| `repo-gardening` | `.opencode/skill/repo-gardening/` | Repository hygiene, file organization |
| `smart-commit` | `.opencode/skill/smart-commit/` | Auto-group changes, atomic commits |
| `vue-perf-tune` | `.opencode/skill/vue-perf-tune/` | Vue 3 + Vite performance optimization |

## Legacy Skills (Reference)

Original skill definitions with full metadata are in `extras/claude-skills/` for reference.

## Usage

**OpenCode**: Skills are auto-discovered from `.opencode/skill/{name}/SKILL.md`

**Claude Code**: Copy skill to `.claude/skills/` and invoke with: `Apply <skill_name> skill to <target_path>`
