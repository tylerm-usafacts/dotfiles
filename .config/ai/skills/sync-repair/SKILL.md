---
name: sync-repair
description: Repairs AI config sync drift and validates generated outputs.
---

# Sync Repair

Use this skill when `sync-ai-config --check` fails, generated agent files drift, or MCP render targets drift (`opencode` `mcp` block / `.mcp.json`).

## Procedure

1. Capture failure signal.
   - Run `sync-ai-config --check` and note drift/failure.

2. Gather quick diagnostics.
   - Run `git status` and `git diff`.
   - Confirm dependencies: `jq --version`, `yq --version`.
   - If needed, run `opencode agent list` to inspect generated OpenCode output.
   - If MCP config was touched, run `opencode mcp list` and `claude mcp list` to confirm rendered server presence and auth state.

3. Reconcile canonical to generated outputs.
   - Run `sync-ai-config`.
   - Re-run `sync-ai-config --check`.

4. If drift persists, isolate source.
   - Confirm edits were made under `.config/ai/` canonical paths.
   - Confirm generated files are not being edited directly.
   - Re-check for stale symlink or stow state and use `dotfiles sync` if needed.

5. Report closure.
   - State whether drift is resolved.
   - List files changed and verification commands run.

## Guardrails

- Never edit generated targets as source of truth.
- Do not suppress sync failures; surface blockers clearly.
- Keep repair changes minimal and reversible.
