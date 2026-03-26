# Shared custom agents

This directory is the canonical source for custom agents shared across Claude Code and OpenCode.

## Author here only

- Create one file per agent: `<agent-id>.md`
- Use YAML frontmatter + markdown body
- Required frontmatter keys: `name`, `description`
- Prefer `mode: subagent` for specialist helper agents

## Canonical format

```md
---
name: code-reviewer
description: Reviews code for security and maintainability
mode: subagent
model: sonnet
maxTurns: 12
disallowedTools: Write, Edit
permission:
  edit: deny
---
You are a focused code review agent.
```

- Frontmatter = metadata/config
- Body = agent prompt/instructions

## Sync behavior

Run:

- `sync-ai-config` to apply changes
- `sync-ai-config --check` to detect drift

Sync output locations:

- Claude: `~/.claude/agents/*.md`
- OpenCode: `~/.config/opencode/agents/*.md`

Generated files include a marker and should not be edited directly.

## Field compatibility notes

`sync-ai-config` maps canonical fields to tool-native schemas.

- `maxTurns` is used for Claude output
- `steps` is used for OpenCode output
- If one is present and the other is absent, sync maps automatically:
  - `steps -> maxTurns` for Claude
  - `maxTurns -> steps` for OpenCode

## Tooling requirements

`sync-ai-config` requires:

- `yq` (mikefarah/yq)
- `jq`

## Troubleshooting

- Missing `name` or `description`: sync fails with a validation error.
- Missing `yq`/`jq`: install dependencies, then rerun sync.
- `--check` reports drift: run `sync-ai-config` to reconcile generated files.
