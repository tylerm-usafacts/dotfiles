---
name: confluence-full-context-retrieval
description: Retrieve full Confluence page context in chunks for planning, avoiding output-size truncation and premature summarization.
---

# Confluence Full Context Retrieval

Use this skill when the user asks to ingest, retrieve, or provide full context for a Confluence page, especially for long PRDs, TDDs, architecture pages, rollout plans, or source documents used to build broader plans.

## Goal

Preserve exact page context across output-size limits by retrieving the page in bounded chunks and verifying coverage against the page outline.

## Defaults

- Retrieval is read-only unless the user separately and explicitly requests page creation or edits.
- Do not summarize globally during full-context ingestion.
- Prefer exact content over summaries.
- If exact content does not fit, split into smaller heading ranges or subheading chunks instead of summarizing.
- If summary is unavoidable after reducing chunk size, label it clearly as a summary and identify the exact-content boundary that could not be returned.
- Keep Jira/Confluence mutation workflows separate from retrieval workflows.
- The conversation context window is finite. For very large documents, recommend durable artifact storage only when the user grants explicit write/mutation permission.

## Workflow

### Phase 1: Outline and chunk plan

Retrieve only the page discovery information:

- page ID
- title
- URL
- parent ID if available
- current page version
- full heading outline
- estimated size by section if available
- whether all content can fit in one response
- proposed chunk plan using heading ranges

If chunking is needed, stop after returning the plan. Do not retrieve the first content chunk unless the user already asked the current task to proceed through all chunks autonomously.

### Phase 2: Chunk retrieval

Retrieve bounded chunks by heading range.

Each chunk response must include:

- page ID
- page version
- chunk number
- heading path or heading range
- start marker
- end marker
- exact section content where possible
- truncation status
- next recommended chunk

If a requested heading range is too large, split it into smaller subchunks and return the smaller chunk. Do not silently summarize a too-large section.

### Phase 3: Coverage verification

After all planned chunks are retrieved, compare collected chunks against the original outline.

Return a coverage table with:

- every heading
- retrieved chunk ID or number
- coverage status: full, partial, or missing
- truncation status
- recommended follow-up chunks

Only after coverage verification should you provide a synthesis or evaluation, and only if requested.

## Initial Retrieval Prompt Pattern

```text
Read-only task. Retrieve Confluence page PAGE_ID in chunks.

Do not summarize the page globally yet.

Step 1:
Return only:
- page metadata
- full heading outline
- estimated size by section if available
- proposed chunk plan using heading ranges
- page version
- whether all content can fit in one response

Then stop if chunking is needed.

For later continuation calls, retrieve only the requested chunk:
- chunk number
- heading range
- exact content for those headings
- start marker and end marker
- whether anything was truncated
- next recommended chunk

If any content is too large for one response, split that heading into smaller subchunks instead of summarizing.

Do not create, edit, or mutate Jira/Confluence content.
```

## Continuation Prompt Pattern

```text
Continue the same retrieval task.

Retrieve chunk N for page PAGE_ID, version VERSION.

Heading range:
- START_HEADING
- through END_HEADING

Return exact content for this range only.

Include:
- chunk number
- heading path
- start/end markers
- truncation status
- next chunk recommendation

Do not summarize unless exact content cannot be returned; if exact content cannot be returned, say so and split into a smaller chunk.
```

## Completion Verification Prompt Pattern

```text
Verify retrieval completeness for page PAGE_ID.

Compare the collected chunks against the original outline.

Return:
- every heading
- retrieved chunk ID
- coverage status: full / partial / missing
- any truncation
- recommended follow-up chunks

Do not mutate anything.
```

## Output Contract

For full-context retrieval tasks, return:

- retrieval mode used: single response or chunked
- page metadata and version
- chunk plan or retrieved chunk details
- truncation status
- coverage verification status when complete
- any remaining gaps

## Guardrails

- Do not mutate Jira or Confluence during retrieval.
- Do not claim full context was retrieved until coverage verification passes.
- Do not treat a faithful summary as exact source content.
- Do not mix page-edit instructions into retrieval chunks unless the user separately requested APPLY.
