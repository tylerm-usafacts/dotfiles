# Shared AI Configuration

This directory is the canonical source for AI configuration shared across Claude Code and OpenCode.

## Layout

- `AGENTS.md` - shared behavioral instructions loaded by both tools
- `agents/*.md` - custom agent definitions (canonical source)
- `skills/*/SKILL.md` - reusable process skills
- `docs/policies/*.md` - always-on rules and guardrails
- `docs/runbooks/*.md` - operational procedures and troubleshooting steps
- `docs/references/*.md` - lookup docs, schemas, and mappings
- `docs/doc-classification-rubric.md` - guide for placing new docs
- `mcp/servers.json` - canonical MCP server definitions

## Document placement rules

- Keep skill-specific assets next to the skill in `skills/<skill-name>/`.
- Use `docs/policies/` for normative guidance that should always apply.
- Use `docs/runbooks/` for step-by-step operational procedures.
- Use `docs/references/` for lookup material and field mappings.
- If a skill depends on a shared document, link it with an explicit relative path.

## Documentation index

Policies:

- `docs/policies/code-changes.md`
- `docs/policies/style-and-comments.md`
- `docs/policies/git-and-safety.md`
- `docs/policies/communication-and-planning.md`
- `docs/policies/tool-usage.md`

Runbooks:

- `docs/runbooks/sync-and-bootstrap.md`
- `docs/runbooks/mcp-troubleshooting.md`
- `docs/runbooks/package-onboarding-validation.md`

References:

- `docs/references/ai-config-field-reference.md`
- `docs/references/core-principles.md`
- `docs/references/language-patterns.md`
- `docs/references/mcp-config-reference.md`
- `docs/references/mcp-dsl-mapping.md`
- `docs/references/package-installer-conventions.md`

Classification:

- `docs/doc-classification-rubric.md`

## Dotfiles-manager stack

Current focused setup:

- Agent: `agents/dotfiles-manager.md`
- Skills: `skills/skill-creator`, `skills/package-onboarding`, `skills/sync-repair`
- References: `docs/references/core-principles.md`, `docs/references/language-patterns.md`, `docs/references/ai-config-field-reference.md`, `docs/references/package-installer-conventions.md`, `docs/references/mcp-config-reference.md`, `docs/references/mcp-dsl-mapping.md`
- Runbooks: `docs/runbooks/sync-and-bootstrap.md`, `docs/runbooks/mcp-troubleshooting.md`

Usage guidance:

- Keep root `AGENTS.md` minimal and stable; place broad guardrails in `docs/policies/`.
- Keep procedural workflows in skills.
- Keep larger lookup material in references and load only when needed.
- Keep ordered operational command sequences in runbooks.

## Custom agent authoring

- Create one file per agent: `<agent-id>.md`
- Use YAML frontmatter followed by a markdown prompt body
- Required frontmatter keys: `name`, `description`
- Prefer `mode: subagent` for specialist helpers

Canonical example:

```md
---
name: code-reviewer
description: Reviews code for security and maintainability
mode: subagent
model: openai/gpt-5.1-codex-mini
maxTurns: 8
permission:
  edit: deny
  bash:
    "*": ask
    git status: allow
---
You are a focused code review agent.
```

- Frontmatter is metadata/config
- Body is the agent prompt/instructions

## Sync workflow

Run:

- `sync-ai-config` to apply changes
- `sync-ai-config --check` to detect drift

MCP sync behavior:

- Canonical MCP source: `.config/ai/mcp/servers.json`
- OpenCode target: `~/.config/opencode/opencode.json` (`mcp` block)
- Claude target: `~/dotfiles/.mcp.json` (`mcpServers`)
- OAuth credentials and auth caches remain runtime state and are not source files.
- Mapping reference: `.config/ai/docs/references/mcp-dsl-mapping.md`

Sync output locations:

- Claude: `~/.claude/agents/*.md`
- OpenCode: `~/.config/opencode/agents/*.md`

Generated files include a marker and should not be edited directly.

## Field compatibility

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
