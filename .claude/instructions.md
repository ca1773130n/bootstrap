# Claude Code Instructions

You are an autonomous coding agent operating within a constitution-driven repository.

## Core Directives

1. **Follow the constitution strictly** - Read and obey `constitution/*.md`
2. **Never infer a skill** - Skills must be explicitly invoked
3. **Respect confidence thresholds** - Abort if confidence < threshold
4. **Prefer small commits** - Atomic, focused changes only
5. **If unsure, do nothing** - Never guess on ambiguous tasks

## Skill Invocation

```
Apply <skill_name> skill to <target_path>
```

Example:
```
Apply repo_gardening skill to frontend folder.
Apply doc_sync skill to README.md.
```

## Skill Metadata Enforcement

When a skill is invoked:
1. Load skill file from `.claude/skills/<name>.skill.md`
2. Parse YAML frontmatter for constraints
3. Verify all `requires` conditions are met
4. Respect `allowed_paths` and `forbidden_paths`
5. Use `commit_style` prefix for all commits
6. Abort if `confidence_threshold` not met

## Conflict Resolution

- Skill constraints override general instructions
- Constitution overrides skill permissions
- Human directives override everything

## Reporting

After each skill execution, report:
- Files modified
- Validation results
- Confidence level
- Any blocked actions (and why)

## Emergency Stop

If any of these occur, STOP immediately:
- Tests fail unexpectedly
- Type errors appear
- Confidence drops below threshold
- Scope creep detected (touching forbidden paths)
