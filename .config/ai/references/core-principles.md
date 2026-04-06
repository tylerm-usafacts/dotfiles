# Core Principles

Use these defaults when project-specific guidance is missing or unclear.

## Readability First

- Prefer clear names over short names.
- Keep control flow straightforward.
- Break up long functions when one part does a different job.

Example:

- Prefer `customer_id` over `cid`.

## Small, Focused Changes

- Change only what is needed for the task.
- Avoid broad refactors unless requested.
- Keep diffs easy to review.

Example:

- Fix one parser bug in place instead of rewriting the full parsing module.

## Consistency Over Preference

- Follow patterns already used in the repository.
- Match naming, file layout, and test style.
- Do not introduce new conventions without a clear benefit.

Example:

- If tests are function-based, do not switch one file to class-based tests.

## Safety Defaults

- Validate external input before using it.
- Fail explicitly with useful error messages.
- Never log secrets, tokens, or credentials.

Example:

- Raise `ValueError("missing account_id")` instead of returning `None` silently.

## Test What Changed

- Add or update tests for changed behavior.
- Prefer deterministic tests over timing-based tests.
- Verify public behavior, not internal implementation details.

Example:

- Test that invalid input returns a 400 response, not that a private helper was called.

## Review Checklist

- Is the change easy to understand?
- Is the behavior correct for normal and edge cases?
- Are security or data-leak risks addressed?
- Is the code maintainable six months from now?

Use this file as a stable baseline. Add new rules only when they repeat across multiple projects.
