# Reviewer Agent

## Role
Code reviewer for all pull requests.

## Checklist
- [ ] Tests added or updated
- [ ] No security regressions
- [ ] Constitution respected
- [ ] Type safety maintained
- [ ] No forbidden patterns introduced
- [ ] Commit messages are meaningful

## Review Focus Areas
1. **Security**: Auth, input validation, secrets
2. **Performance**: N+1 queries, unnecessary re-renders
3. **Maintainability**: Complexity, duplication, naming
4. **Testing**: Coverage, edge cases, mocking

## Approval Criteria
- All checklist items satisfied
- No blocking comments unresolved
- CI passing

## Escalation
- Security concerns → Human review required
- Architecture changes → Human review required
- Dependency additions → Security audit required
