# MCP Config Reference

Use this reference when updating canonical MCP server config.

For field-level translation rules and render examples, see `.config/ai/docs/references/mcp-dsl-mapping.md`.

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

## Sync Mapping (Quick)

`sync-ai-config` maps canonical MCP config into tool-specific targets:

- OpenCode target: `~/.config/opencode/opencode.json` (`mcp` block only)
- Claude target: `~/dotfiles/.mcp.json` (`mcpServers` file)
