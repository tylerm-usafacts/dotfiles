# AI Config Field Reference

Use this reference when editing `.config/ai/agents/*.md` and validating sync behavior.

## Canonical Source of Truth

- Author custom agents in `.config/ai/agents/*.md`.
- Keep shared instructions in `.config/ai/AGENTS.md`.
- Keep reusable procedures in `.config/ai/skills/*/SKILL.md`.
- Run `sync-ai-config` to render tool-native outputs.

## Frontmatter Core Fields

- `name`: stable agent identifier.
- `description`: short purpose statement.
- `mode`: usually `subagent` for specialists.
- `model`: chosen model id.
- `maxTurns`: canonical turn budget.
- `skills`: explicit skill allowlist for the agent.
- `permission`: command and tool policy.

## Field Mapping Behavior

`sync-ai-config` maps turn budget keys between targets:

- `maxTurns -> steps` for OpenCode output.
- `steps -> maxTurns` for Claude output.

## Generated Output Rules

- Generated files include the sync marker.
- Generated outputs are not source files.
- Drift should be fixed by sync, not by editing generated files.
