# Engineering Principles

## Code Quality
- Type everything: TypeScript strict mode, Python type hints
- Test first for critical paths
- One concern per file, one responsibility per function

## Architecture
- Backend: Async-first, no blocking IO
- Frontend: Composition API, minimal global state
- API: RESTful, consistent error shapes

## Dependencies
- Prefer stdlib over external packages
- Lock all dependency versions
- Audit before adding new dependencies

## Performance
- Lazy load non-critical paths
- Cache aggressively at API layer
- Measure before optimizing

## Security
- Never trust client input
- Parameterize all queries
- Secrets in environment only
