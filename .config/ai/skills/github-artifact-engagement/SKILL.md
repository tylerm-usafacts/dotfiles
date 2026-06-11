---
name: github-artifact-engagement
description: Draft-only GitHub PR, issue, comment, review, checks, workflow, notification, and repository engagement workflow.
---

# GitHub Artifact Engagement

Use this skill when the user asks to review, triage, summarize, or draft engagement for GitHub pull requests, issues, comments, reviews, checks, workflow runs, notifications, releases, or repository metadata.

## Goal

Gather enough GitHub context to produce accurate draft-only engagement while avoiding unintended remote mutations.

## Defaults

- Operate in draft-only mode.
- Do not mutate GitHub artifacts.
- The GitHub MCP server is configured with `X-MCP-Readonly: true` where available.
- If GitHub MCP is unavailable, use read-only `gh` CLI commands when possible.
- If a user asks to post or perform an action, draft the content/action plan and state that no GitHub mutation was performed.
- Do not treat `APPLY` as approval for GitHub mutation in this version.

## Workflow

### Phase 1: Resolve target

Identify and state:

- owner
- repository
- artifact type: PR, issue, comment, review, check, workflow run, notification, release, or repository
- artifact number, ID, branch, commit SHA, or URL when available

If the target is ambiguous, ask one short clarifying question with the most likely default.

### Phase 2: Collect context

Use GitHub MCP read tools where available.

For pull requests, collect relevant:

- title, author, state, base/head branches
- description/body
- changed files and diff summary
- review comments and conversation status
- check suite or workflow status
- linked issues when visible

For issues, collect relevant:

- title, author, state, labels, assignees, milestone
- body and current acceptance criteria or reproduction details
- comments and timeline context
- linked PRs or related issues when visible

For comments or reviews, collect relevant:

- target thread or review location
- prior discussion context
- current requested response or decision

For actions/checks, collect relevant:

- workflow name, run ID, branch, commit SHA
- failing jobs and log evidence when available
- rerun or remediation recommendation, draft-only

For notifications, collect relevant:

- reason, repository, subject, URL, unread/action-needed status
- recommended triage action, draft-only

### Phase 3: Analyze

Separate:

- observed facts
- inferred causes
- risks or blockers
- missing context
- suggested response or action

For PR reviews, prioritize correctness, security, data loss, regression risk, and missing tests before style or preference comments.

For issue triage, identify whether the issue is actionable, missing reproduction details, duplicated, blocked, or ready for implementation.

### Phase 4: Draft output

Return the exact draft content the user can manually post.

Common draft types:

- PR review summary
- inline review comment text
- issue reply
- triage note
- maintainer response
- CI failure summary
- label/assignee/milestone recommendation
- notification triage list

### Phase 5: Mutation refusal

If the user asks to mutate GitHub, respond with:

- the drafted content or action list
- the exact target artifact
- manual posting/action instructions
- `Draft-only mode: no GitHub mutation performed.`

Do not call GitHub write tools, even after `APPLY`.

## Output Contract

Return:

- target artifact and URL when available
- context reviewed
- findings or triage summary
- draft content/action list
- suggested manual next step
- `Draft-only mode: no GitHub mutation performed.`

## Guardrails

- Do not post comments, submit reviews, approve PRs, request changes, merge PRs, close issues, add labels, assign users, mark notifications read, rerun workflows, trigger workflows, create branches, create commits, delete comments, or edit artifacts.
- Do not claim a PR was reviewed completely unless the diff, discussion, and checks were actually inspected or the remaining gaps are stated.
- Do not invent maintainer intent, CI results, branch protections, or reviewer consensus.
- Do not expose secrets from logs or comments in draft text.
