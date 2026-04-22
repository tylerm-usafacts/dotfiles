# MCP Troubleshooting Runbook

Use this runbook for MCP configuration drift, validation failures, or runtime mismatch across tools.

## Preconditions

- Canonical source is `.config/ai/mcp/servers.json`.
- Do not edit generated runtime targets directly.

## Validate Canonical and Sync

1. Validate canonical edits and repository scope.
   - `git status`
   - `git diff`
2. Run sync and drift check.
   - `sync-ai-config`
   - `sync-ai-config --check`

## Verify Runtime State

- OpenCode: `opencode mcp list`
- Claude: `claude mcp list` or `/mcp`

## Common Failure Modes

- `mcpServers` key missing or invalid object shape.
- `stdio` server missing `command`.
- Remote server missing `url`.
- Auth state missing for OAuth-backed providers.

## Remediation

- Fix schema issues in `.config/ai/mcp/servers.json`.
- Re-run `sync-ai-config` and `sync-ai-config --check`.
- Re-verify MCP runtime state in both tools.

## Security Notes

- Never commit OAuth tokens or auth caches.
- Keep secrets out of canonical source.
