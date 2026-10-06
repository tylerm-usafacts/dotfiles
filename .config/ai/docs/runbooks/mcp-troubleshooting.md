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

## Datadog OAuth

1. Confirm the selected Datadog regional endpoint and `toolsets` URL query in `.config/ai/mcp/servers.json`.
2. Restart OpenCode after syncing configuration, then run `opencode mcp auth datadog` if browser authentication does not start automatically.
3. If OAuth redirects are rejected by the Datadog organization, allow-list `http://127.0.0.1:19876/mcp/oauth/callback` in Datadog Organization Preferences.
4. Confirm the authenticated role has `mcp_read` and the resource-level permissions needed for the requested data.

## Fellow OAuth

1. Confirm the Fellow endpoint is `https://fellow.app/mcp` in `.config/ai/mcp/servers.json` and that no static OAuth override or bearer token is configured.
2. Run `sync-ai-config`, restart OpenCode, then run `opencode mcp auth fellow` if dynamic discovery does not open the Fellow authorization flow automatically.
3. Complete Fellow OAuth in the browser and verify `opencode mcp list` reports the server as authenticated.
4. Verify a read-only request against a non-sensitive meeting. If discovery or authorization fails, capture the client error and consult Fellow's MCP connection instructions before adding any local-only credential variable.

## Security Notes

- Never commit OAuth tokens or auth caches.
- Keep secrets out of canonical source.
