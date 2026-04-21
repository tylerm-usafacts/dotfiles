---
name: jira-board-audit
description: Audit a Jira board and its epics with clear assumptions, board metadata, and risk flags.
---

# Jira Board Audit

Use this skill for requests like "review board epics", "what is active/stale", or "audit board health".

## Procedure

1. Resolve board scope first.
   - Try to identify board by provided name.
   - If board lookup is unavailable, use best project match and state the assumption.
   - Capture board metadata: board name, board id (if available), project keys, and filter/JQL (if available).

2. Collect epic set.
   - Retrieve epics in board scope.
   - For each epic: key, summary, status, assignee, priority, updated date.
   - Count child issues when possible.

3. Compute health flags.
   - Active epics: in-progress workflow states.
   - Stale epics: no updates in last 30 days unless user gives another threshold.
   - Empty epics: zero child issues.
   - Overlap risks: similar names/scope that suggest duplicate or conflicting workstreams.

4. Return a concise audit package.
   - Board identified (name + id + assumptions)
   - Epic table
   - Findings (active, stale, empty, overlap/risk)
   - Suggested next review actions (read-only unless user explicitly requests APPLY)

## Guardrails

- Default to read-only analysis.
- Do not mutate Jira or Confluence unless user explicitly says APPLY.
- If board identity is ambiguous, state best match and continue.
