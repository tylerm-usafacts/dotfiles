# Package Installer Conventions

Use this reference when adding or repairing entries in `packages.json` and installer logic in `install.sh`.

## Installer Mode Decision

- Start with package-manager mode (`brew` on macOS, `apt` on Linux).
- If package-manager install is unavailable for either OS, use `custom` installer functions for that OS.
- Use `native` only when install and detect scripts are explicitly provided and deterministic.

## `packages.json` Shape

- Keep per-package installer structure explicit by OS.
- Prefer existing repository formatting and key order.
- For custom installers, point to OS-specific wrapper names:
  - `install_macos_<name>` for macOS
  - `install_linux_<name>` for Linux

## Idempotent Detect Patterns

- Use explicit checks that succeed only when the tool is already installed.
- Avoid brittle regex shortcuts; prefer anchored patterns with whitespace boundaries.

## Related Procedure

- For step-by-step validation and execution flow, use `.config/ai/docs/runbooks/package-onboarding-validation.md`.
