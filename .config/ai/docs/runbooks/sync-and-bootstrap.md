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

## GitHub MCP Secret Bootstrap

1. Copy the tracked template to the ignored secret-file location.
   - `cp ~/.config/ai/secrets.env.example ~/.config/ai/secrets.env`
2. Replace the placeholder with a fine-grained PAT that has access only to the required repositories and read permissions.
3. Restrict the file to the current user.
   - `chmod 600 ~/.config/ai/secrets.env`
4. Start OpenCode or Claude through the tracked wrappers. They sync configuration, load `GITHUB_PERSONAL_ACCESS_TOKEN`, and then execute the real binary.
5. Confirm the GitHub MCP is connected.
   - `opencode mcp list`

`~/.config/ai/secrets.env` is a local-only runtime file, not a repository file. Do not create `~/dotfiles/.config/ai/secrets.env`; the repository ignores that path only to prevent an accidental secret commit. The template, location, variable name, wrappers, and MCP configuration are tracked so a new machine only needs a newly issued token.

## Post-Repair Verification

- `sync-ai-config --check` exits cleanly.
- `git status` shows only expected changes.
- Generated agent files reflect canonical source and include generated marker.
