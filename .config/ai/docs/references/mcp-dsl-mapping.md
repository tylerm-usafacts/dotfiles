# MCP DSL Mapping

This document defines how canonical MCP config in `.config/ai/mcp/servers.json` maps to OpenCode and Claude runtime config.

## Canonical Source

- File: `.config/ai/mcp/servers.json`
- Required top-level key: `mcpServers` (object)

## Render Targets

- OpenCode: `~/.config/opencode/opencode.json` (managed `mcp` block only)
- Claude project scope: `~/dotfiles/.mcp.json` (managed full file)

## Field Mapping

| Canonical | OpenCode output | Claude output |
| --- | --- | --- |
| `type: "http"` | `type: "remote"` | `type: "http"` |
| `type: "sse"` | `type: "remote"` | `type: "sse"` |
| `url` | copied | copied |
| `type: "stdio"` | `type: "local"` | `type: "stdio"` |
| `command` (stdio, string) | normalized to array with `args` appended if present | kept as string |
| `command` (stdio, array) | kept as array | split to `command` (first token) plus `args` (rest) |
| `env` (stdio) | mapped to `environment` | kept as `env` |
| `enabled` | copied | removed |

## Operational Checklist

1. Edit `.config/ai/mcp/servers.json`.
2. Run `sync-ai-config`.
3. Run `sync-ai-config --check`.
4. Verify runtime state:
   - `opencode mcp list`
   - `claude mcp list` or `/mcp`
