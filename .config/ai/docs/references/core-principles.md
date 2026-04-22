# Core Principles

Use these defaults when project-specific guidance is missing or unclear.

## Readability First

- Prefer clear names over short names.
- Keep control flow straightforward.
- Break up long functions when one part does a different job.

## Small, Focused Changes

- Change only what is needed for the task.
- Avoid broad refactors unless requested.
- Keep diffs easy to review.

## Consistency Over Preference

- Follow patterns already used in the repository.
- Match naming, file layout, and test style.
- Do not introduce new conventions without a clear benefit.

## Safety Defaults

- Validate external input before using it.
- Fail explicitly with useful error messages.
- Never log secrets, tokens, or credentials.

## Test What Changed

- Add or update tests for changed behavior.
- Prefer deterministic tests over timing-based tests.
- Verify public behavior, not internal implementation details.
