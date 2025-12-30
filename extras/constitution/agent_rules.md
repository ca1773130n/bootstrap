# Agent Rules

## Git Workflow
- Agents must never push directly to main
- All changes via feature branches
- Branch naming: `auto/<skill-name>` or `feat/<description>`

## Before Committing
- Run all relevant tests
- Ensure linting passes
- Verify no type errors

## Scope Boundaries
- Refactoring must preserve public APIs unless explicitly told
- Infrastructure changes require explicit human approval
- Database migrations require explicit human approval

## Uncertainty Protocol
- If confidence < 0.7, stop and report
- If task scope unclear, ask for clarification
- If multiple valid approaches exist, propose options

## Collaboration
- One skill per run unless chained explicitly
- Document reasoning in commit messages
- Tag related issues in commits
