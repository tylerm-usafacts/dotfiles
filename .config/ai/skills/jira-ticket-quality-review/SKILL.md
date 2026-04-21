---
name: jira-ticket-quality-review
description: Review Jira ticket quality by type (Story, Bug, Spike) and produce concrete refinement recommendations.
---

# Jira Ticket Quality Review

Use this skill when reviewing, refining, or rewriting a Jira ticket.

Companion templates in this directory:
- `story-ticket-template.md`
- `bug-ticket-template.md`
- `spike-ticket-template.md`

## Procedure

1. Resolve ticket type before review.
   - Prefer Jira issue type if available.
   - Map types: Story/Task/Improvement -> Story path; Bug/Defect -> Bug path; Spike/Research -> Spike path.
   - If unclear, ask once and continue with user-confirmed type.

2. Ingest ticket content.
   - Retrieve by key/URL with Atlassian tools.
   - If retrieval fails, ask user to paste content and stop until input is provided.

3. Establish baseline and target change.
   - Capture current-state baseline (what already exists/works today).
   - Capture requested change objective (what this ticket should newly deliver).
   - Mark assumptions as confirmed or unconfirmed from user context.

4. Run type-specific rubric.
   - Story path: goal clarity, acceptance criteria quality, scope boundaries, dependencies, edge cases.
   - Bug path: reproducibility, environment, expected vs actual, evidence, impact, regression context.
   - Spike path: question/hypothesis, time box, success criteria, deliverables, out-of-scope boundaries.
   - Title quality: outcome-focused end state, concise, avoids internal option labels unless user requested.
   - Tone quality: avoid overprescriptive implementation bans unless user explicitly requires them.

5. Produce output.
   - Short summary of ticket as received.
   - Baseline vs change objective.
   - Gap matrix with status: present, partial, missing.
   - Focused clarification questions.
   - Readiness verdict: ready, caution, not ready.
   - Drafted replacement or additive sections using the matching template.
   - Acceptance criteria split into invariants and change criteria.

6. Run final ticket lint before output.
   - Business value reflects the actual gap (not already-solved problems).
   - Scope and non-goals are consistent and non-conflicting.
   - Constraints and fallback behavior are documented when platform limits may apply.

## Guardrails

- Do not use Story-only criteria for Bug/Spike tickets.
- Do not invent missing facts; mark assumptions explicitly.
- Do not overprescribe architecture/implementation unless user direction requires it.
- Default to PLAN/read-only; only apply edits if user explicitly says APPLY.
