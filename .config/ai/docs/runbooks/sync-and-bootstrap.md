# Sync and Bootstrap Runbook

Use this runbook for machine setup failures, AI-config drift, and sync validation.

## Common Failure Classes

- Missing dependency (`jq`, `yq`, `stow`, package manager).
- Wrong dependency variant (`yq` not mikefarah build).
- Symlink conflicts or stale stow state.
- Shell path mismatch (`~/.local/bin` not first in `PATH`).
- Package install mismatch across macOS and Linux.

## Triage Steps

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
4. If drift remains, reconcile and re-check.
   - `sync-ai-config`
   - `sync-ai-config --check`

## yq Variant Check

- Expected signal: `yq --version` contains `mikefarah`.
- If variant is wrong, install mikefarah `yq` and rerun `sync-ai-config --check`.

## Generated File Rules

- Canonical source is `.config/ai/*`.
- Generated outputs under `~/.config/opencode/agents/*.md` and `~/.claude/agents/*.md` are derived artifacts.
- Never patch generated output directly.

## Post-Repair Verification

- `sync-ai-config --check` exits cleanly.
- `git status` shows only expected changes.
- Generated agent files reflect canonical source and include generated marker.
