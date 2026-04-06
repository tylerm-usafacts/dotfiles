# Bootstrap Runbook

Use this reference for machine setup failures and environment drift. This is a lookup document, not a default instruction set.

## Common Failure Classes

- Missing dependency (`jq`, `yq`, `stow`, package manager).
- Wrong dependency variant (`yq` not mikefarah build).
- Symlink conflicts or stale stow state.
- Shell path mismatch (`~/.local/bin` not first in PATH).
- Package install mismatch across macOS and Linux.

## Fast Triage Sequence

1. Check working tree and scope.
   - `git status`
   - `git diff`

2. Verify required binaries.
   - `python3 --version`
   - `jq --version`
   - `yq --version`

3. Verify tool wiring.
   - `dotfiles sync`
   - `sync-ai-config --check`

4. If check fails, reconcile.
   - `sync-ai-config`
   - `sync-ai-config --check`

## yq Variant Check

`sync-ai-config` expects mikefarah `yq`.

Expected signal:

- `yq --version` contains `mikefarah`.

If wrong variant is installed:

- install the mikefarah version,
- re-run `sync-ai-config --check`.

## Symlink and Generated File Rules

- Canonical source is `.config/ai/*`.
- Generated outputs under `~/.config/opencode/agents/*.md` and `~/.claude/agents/*.md` are derived artifacts.
- Never patch generated output directly.
- Use `sync-ai-config` to reconcile drift.

## Stow/Link Conflict Hints

- If symlink checks look correct but drift remains, run `dotfiles sync` to re-apply install + stow + AI sync workflow.
- Re-check with `sync-ai-config --check`.

## Post-Repair Verification

- `sync-ai-config --check` exits cleanly.
- `git status` shows only expected changes.
- Generated agent files reflect canonical source and include generated marker.

## Additions Over Time

When adding new troubleshooting entries, include:

- Symptom
- Root cause
- Fix
- Verification command
