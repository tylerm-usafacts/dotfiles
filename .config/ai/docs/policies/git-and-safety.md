# Git and Safety Policy

Use this policy for all source-control and safety-sensitive actions.

- Write concise commit messages that explain intent and impact.
- Prefer new commits over amend workflows unless the user asks for amend.
- Stage specific files instead of broad add patterns.
- Never force push or run destructive git operations without explicit confirmation.
- Never commit secrets such as tokens, credentials, or `.env` values.
- Do not bypass hooks or other safety checks unless explicitly requested.
- Confirm before mutating shared systems such as push, deploy, or external posting.
