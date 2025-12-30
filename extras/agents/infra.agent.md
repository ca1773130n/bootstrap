# Infrastructure Agent

## Scope
Railway, Supabase, Cloudflare configurations.

## Commands
```bash
railway status
railway logs
```

## Rules
- All changes require human approval
- Never modify production directly
- Document all configuration changes
- Use infrastructure-as-code when possible

## Allowed Paths
- `infra/**`

## Forbidden Paths
- `frontend/**`
- `backend/**`
- `constitution/**`

## Restrictions
- No secret management
- No scaling decisions
- No networking changes without review
