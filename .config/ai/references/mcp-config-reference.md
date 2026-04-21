# MCP Config Reference

Use this reference when updating canonical MCP server config.

For field-level translation rules and concrete render examples, see `.config/ai/references/mcp-dsl-mapping.md`.

## Canonical Source

- Source file: `.config/ai/mcp/servers.json`
- Required top-level key: `mcpServers` (object)

## Canonical Schema (Quick)

Each server entry must include one of:

- Remote server:
  - `type`: `http` or `sse`
  - `url`: full MCP endpoint URL
- Local stdio server:
  - `type`: `stdio`
  - `command`: string or array

Optional keys:

- `enabled` (OpenCode only)
- `headers`
- `oauth`
- `timeout`
- `env` (for stdio)

## Sync Mapping (Quick)

`sync-ai-config` maps canonical MCP config into tool-specific targets:

- OpenCode target: `~/.config/opencode/opencode.json` (`mcp` block only)
- Claude target: `~/dotfiles/.mcp.json` (`mcpServers` file)

Detailed mapping semantics are defined in `.config/ai/references/mcp-dsl-mapping.md`.

## Validation Workflow

1. Edit `.config/ai/mcp/servers.json`.
2. Run `sync-ai-config`.
3. Run `sync-ai-config --check`.
4. Verify with:
   - `opencode mcp list`
   - `/mcp` inside Claude

## Auth and Secrets

- Use OAuth for Atlassian Rovo MCP where possible.
- Do not store OAuth tokens or auth caches in git.
- Keep headers/secrets out of canonical source unless they are non-sensitive.
