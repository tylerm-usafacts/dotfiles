# Package Onboarding Validation Runbook

Use this runbook after adding or updating package onboarding logic in `packages.json` or `install.sh`.

## Preconditions

- Package definition changes are complete.
- Installer function changes are saved.

## Validation Sequence

1. Validate package manifest syntax.
   - `jq empty packages.json`
2. Validate installer script syntax when changed.
   - `bash -n install.sh`
3. Apply dotfiles workflow.
   - `dotfiles sync`
4. Confirm scope of resulting changes.
   - `git status`
   - `git diff`

## AI Config Follow-Up

If your change touched `.config/ai/*`, also run:

1. `sync-ai-config`
2. `sync-ai-config --check`

## Success Criteria

- Validation commands exit successfully.
- `git status` only shows expected files.
- No sync drift remains after `sync-ai-config --check`.
