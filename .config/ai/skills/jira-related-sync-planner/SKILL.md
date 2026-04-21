---
name: jira-related-sync-planner
description: Find and triage related Jira and Confluence artifacts that should be aligned after ticket or requirement changes.
---

# Jira Related Sync Planner

Use this skill when the user asks to find related tickets/pages, align docs, or plan linkage updates.

## Procedure

1. Define the change thesis.
   - Capture what changed and why alignment is needed.
   - If vague, ask one clarifying question before searching.

2. Build search seeds.
   - Keywords: features, components, APIs, error codes, terms.
   - Jira clues: project keys, epics, labels, linked issues.
   - Confluence clues: space keys, page titles, runbooks, ADRs.

3. Discover related artifacts.
   - Search Jira for related issues and potential duplicates/conflicts.
   - Search Confluence for pages with overlapping guidance or outdated references.
   - Prefer high-signal matches over broad low-confidence lists.

4. Triage candidates.
   - For each item include:
     - Why related
     - Recommended action (update, review-only, no-change)
     - Proposed high-level change
     - Risk note

5. Confirm scope for APPLY.
   - Ask user to approve the subset of items to update.
   - If user says APPLY, execute only approved updates and report exactly what changed.

## Output Contract

- Search assumptions and scope
- Triage table of related Jira/Confluence items
- Recommended update set
- Explicit list awaiting approval for APPLY

## Guardrails

- No mass updates without explicit approval.
- Default to PLAN/read-only behavior.
- State uncertainty when similarity is weak.
