# MCP DSL Mapping

This document defines how canonical MCP config in `.config/ai/mcp/servers.json` maps to OpenCode and Claude runtime config.

## Canonical Source

- File: `.config/ai/mcp/servers.json`
- Required top-level key: `mcpServers` (object)

## Canonical Schema

Each server under `mcpServers.<name>` must satisfy one of:

- Remote transport:
  - `type`: `http` or `sse`
  - `url`: string
- Local transport:
  - `type`: `stdio`
  - `command`: string, or array with at least one element

Optional canonical keys:

- `enabled`
- `headers`
- `oauth`
- `timeout`
- `env`
- `args` (used with `command` string for stdio)

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
| `command` (stdio, array) | kept as array | split to `command` (first token) + `args` (rest) |
| `args` (stdio) | used only when `command` is string | passed through when command is string; ignored when command array is normalized |
| `env` (stdio) | mapped to `environment` | kept as `env` |
| `enabled` | copied | removed |
| `headers` | copied for `http`/`sse` | copied |
| `oauth` | copied for `http`/`sse` | copied |
| `timeout` | copied | copied |

## Merge Semantics

- OpenCode output is merged into existing JSON as `. + { mcp: <rendered> }`.
  - All non-`mcp` keys in `opencode.json` are preserved.
  - The `mcp` block is replaced on each sync.
- Claude output writes `~/dotfiles/.mcp.json` as a complete file each sync.

## Validation Rules

`sync-ai-config` fails when:

- `mcpServers` is missing or not an object.
- A server does not satisfy required type-specific fields.

## Worked Examples

### Example A: Remote server

Canonical:

```json
{
  "mcpServers": {
    "atlassian": {
      "type": "http",
      "url": "https://mcp.atlassian.com/v1/mcp",
      "enabled": true
    }
  }
}
```

OpenCode render (`mcp` block):

```json
{
  "atlassian": {
    "type": "remote",
    "url": "https://mcp.atlassian.com/v1/mcp",
    "enabled": true
  }
}
```

Claude render (`.mcp.json`):

```json
{
  "mcpServers": {
    "atlassian": {
      "type": "http",
      "url": "https://mcp.atlassian.com/v1/mcp"
    }
  }
}
```

### Example B: Local stdio server

Canonical:

```json
{
  "mcpServers": {
    "example-local": {
      "type": "stdio",
      "command": ["npx", "-y", "example-mcp"],
      "env": {
        "EXAMPLE_MODE": "readonly"
      },
      "timeout": 10000
    }
  }
}
```

OpenCode render (`mcp` block):

```json
{
  "example-local": {
    "type": "local",
    "command": ["npx", "-y", "example-mcp"],
    "environment": {
      "EXAMPLE_MODE": "readonly"
    },
    "timeout": 10000
  }
}
```

Claude render (`.mcp.json`):

```json
{
  "mcpServers": {
    "example-local": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "example-mcp"],
      "env": {
        "EXAMPLE_MODE": "readonly"
      },
      "timeout": 10000
    }
  }
}
```

## Operational Checklist

1. Edit `.config/ai/mcp/servers.json`.
2. Run `sync-ai-config`.
3. Run `sync-ai-config --check`.
4. Verify runtime state:
   - `opencode mcp list`
   - `claude mcp list` or `/mcp`

## Guardrails

- Do not commit OAuth tokens or auth caches.
- Keep secrets out of canonical MCP config.
- If mapping behavior changes in `sync-ai-config`, update this file in the same change.
