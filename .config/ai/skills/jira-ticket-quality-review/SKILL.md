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

3. Run type-specific rubric.
   - Story path: goal clarity, acceptance criteria quality, scope boundaries, dependencies, edge cases.
   - Bug path: reproducibility, environment, expected vs actual, evidence, impact, regression context.
   - Spike path: question/hypothesis, time box, success criteria, deliverables, out-of-scope boundaries.

4. Produce output.
   - Short summary of ticket as received.
   - Gap matrix with status: present, partial, missing.
   - Focused clarification questions.
   - Readiness verdict: ready, caution, not ready.
   - Drafted replacement or additive sections using the matching template.

## Guardrails

- Do not use Story-only criteria for Bug/Spike tickets.
- Do not invent missing facts; mark assumptions explicitly.
- Default to PLAN/read-only; only apply edits if user explicitly says APPLY.
