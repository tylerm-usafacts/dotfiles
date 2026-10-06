# Agent Instructions

Shared operating defaults for AI agents working in this dotfiles and AI-config repository.

## Always True

- Canonical source of AI config is `.config/ai/*`.
- Do not edit generated outputs in `~/.config/opencode/agents/*.md` or `~/.claude/agents/*.md`.
- Confirm before actions that mutate shared systems (for example push, deploy, or external posting).

## Non-Standard Commands

- `dotfiles sync`
- `dotfiles add <package>`
- `sync-ai-config`
- `sync-ai-config --check`

## Change Delivery

- Use Conventional Commit titles for commits: select a type and, when useful,
  a scope that describes the independently mergeable change.
- Default to one coherent PR targeting `main`. Use a stacked PR only when a
  later change cannot work, be reviewed accurately, or be deployed until an
  earlier change lands.
- Every lower stack PR must be complete, CI-green, independently deployable,
  and safe to merge without higher PRs. Do not put a dependency on a higher
  stack PR.
- Keep tests, required configuration, validation rules, and source updates in
  the same PR when they jointly deliver one behavior. Do not split them merely
  to create stack layers.
- Keep independent changes as separate PRs targeting `main`, even when they
  are part of the same initiative. Never create artificial stack edges to
  describe, group, or sequence parallel work.
- Before building a multi-PR change, state the proposed PR graph and the
  concrete merge or deployment dependency for each stack edge. Apply the
  detailed rules in the `stack` skill when creating or modifying a stack.

## Detailed Guidance

- Policies: [`docs/policies/`](docs/policies/)
- Runbooks: [`docs/runbooks/`](docs/runbooks/)
- References: [`docs/references/`](docs/references/)
- Classification rubric: [`docs/doc-classification-rubric.md`](docs/doc-classification-rubric.md)
