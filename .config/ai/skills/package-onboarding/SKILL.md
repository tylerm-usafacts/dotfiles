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

3. Handle installer fallback immediately when needed.
   - If `dotfiles sync` fails because `brew` or `apt` cannot find the package, switch from default mode to `custom` installer functions in `packages.json`.
   - For GitHub CLI extensions (for example `gh-dash`), use a custom installer that runs `gh extension install <owner>/<extension>` with an explicit pre-check from `gh extension list`.
   - Re-run validation after fallback changes.

4. Validate the result.
    - Confirm update succeeded.
    - Review `packages.json` change for correct installer shape.
    - Review `install.sh` function placement by convention: shared helpers in common area, `install_macos_*` in macOS section, `install_linux_*` in Linux custom section.
    - Run `git status` and `git diff` to verify scoped changes.

5. Validate operational state.
    - Run `jq empty packages.json`.
    - If `install.sh` changed, run `bash -n install.sh`.
    - Run `dotfiles sync` to validate install behavior.
    - If AI config files were touched during the task, run `sync-ai-config` and `sync-ai-config --check`.

## Guardrails

- Do not add both package changes and unrelated refactors in one pass.
- Do not use native install mode without a deterministic detect command.
- Keep install and detect scripts explicit and shell-safe.
- Keep installers idempotent with exact, reliable detect checks.
- Do not stop at a partially-working state after fallback; either finish validation or report one clear blocker.

## Output Requirements

- Package added.
- Mode used (default, native, or custom fallback).
- Any fallback trigger and reason.
- Files changed.
- Verification commands and outcomes.
- Remaining work (must be `none` for success).
