# Package Installer Conventions

Use this reference when adding or repairing entries in `packages.json` and installer logic in `install.sh`.

## Installer Mode Decision

1. Start with package-manager mode (`brew` on macOS, `apt` on Linux).
2. If package-manager install is unavailable for either OS, use `custom` installer functions for that OS.
3. Use `native` only when install and detect scripts are explicitly provided and deterministic.

## `packages.json` Shape

- Keep per-package installer structure explicit by OS.
- Prefer existing repository formatting and key order.
- For custom installers, point to OS-specific wrapper names:
  - `install_macos_<name>` for macOS
  - `install_linux_<name>` for Linux

Example:

```json
{
  "name": "gh-dash",
  "installer": {
    "macos": { "type": "custom", "function": "install_macos_gh_dash" },
    "linux": { "type": "custom", "function": "install_linux_gh_dash" }
  }
}
```

## `install.sh` Placement Convention

- Put shared helper functions in the common helper area near other reusable helpers.
- Put `install_macos_*` wrappers in the macOS section.
- Put `install_linux_*` wrappers and Linux-specific installers in the Linux custom installer section.
- Keep wrappers thin; put shared logic in one helper when behavior is cross-platform.

## Idempotent Detect Patterns

- Use explicit checks that succeed only when the tool is already installed.
- Avoid brittle regex shortcuts; prefer anchored patterns with whitespace boundaries.

Examples:

- Binary check: `command -v <tool> &>/dev/null`
- GH extension check:
  - `gh extension list | grep -qE '(^|[[:space:]])owner/name([[:space:]]|$)'`

## Validation Gates

Run these in order after package onboarding changes:

1. `jq empty packages.json`
2. `bash -n install.sh` (if installer script changed)
3. `dotfiles sync`
4. `git status` and `git diff` to confirm scope

For AI config changes in `.config/ai/*`:

5. `sync-ai-config`
6. `sync-ai-config --check`
