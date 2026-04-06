---
name: package-onboarding
description: Adds packages to dotfiles safely using dotfiles add and validates installer behavior.
---

# Package Onboarding

Use this skill when a request adds a new package to dotfiles package management.

## Procedure

1. Confirm package name and install mode.
   - Default mode: package manager-backed (`dotfiles add <name>`).
   - Native mode: require both `--native` and `--detect`.

2. Apply the package update.
   - Run `dotfiles add <name>` for default mode.
   - Run `dotfiles add <name> --native "<install-script>" --detect "<detect-script>"` for native mode.

3. Validate the result.
   - Confirm update succeeded.
   - Review `packages.json` change for correct installer shape.
   - Run `git status` and `git diff` to verify scoped changes.

4. Validate operational state.
   - Run `dotfiles sync` when install behavior needs validation.
   - If AI config files were touched during the task, run `sync-ai-config` and `sync-ai-config --check`.

## Guardrails

- Do not add both package changes and unrelated refactors in one pass.
- Do not use native install mode without a deterministic detect command.
- Keep install and detect scripts explicit and shell-safe.

## Output Requirements

- Package added.
- Mode used (default or native).
- Files changed.
- Verification commands and outcomes.
