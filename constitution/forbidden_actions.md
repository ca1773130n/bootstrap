# Forbidden Actions

## Secrets & Security
- No secret creation or modification
- No hardcoded credentials
- No disabling security features

## Database
- No destructive migrations without backup plan
- No direct production database access
- No schema changes without migration files

## Dependencies
- No dependency upgrades without tests passing
- No adding dependencies without security audit
- No removing dependencies without impact analysis

## Code Quality
- No suppressing type errors (`as any`, `@ts-ignore`)
- No empty catch blocks
- No deleting tests to make CI pass

## Infrastructure
- No modifying production configs
- No scaling decisions without approval
- No changing networking rules
