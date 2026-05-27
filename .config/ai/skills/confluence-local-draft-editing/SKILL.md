---
name: confluence-local-draft-editing
description: Edit Confluence design documents through local Markdown drafts, Neovim diff review, exact APPLY approval, and safe full-page write-back.
---

# Confluence Local Draft Editing

Use this skill when the user asks to edit, rewrite, restructure, or prepare changes for a Confluence page or design document, especially when the page is long enough to risk token limits.

## Goal

Avoid partial-page corruption by editing a complete local draft, reviewing a local diff, and writing back only the complete approved document body.

## Defaults

- Confluence remains canonical.
- `~/confluence-docs` is the default local-only Git workspace for drafts and review history.
- Retrieval and local edits are allowed in draft mode.
- Remote Confluence mutation requires the exact case-sensitive phrase `APPLY`.
- Do not treat `apply`, `Apply`, "go ahead", "commit it", "ship it", closing Neovim, or verbal approval as authorization.
- Prefer exact page content over summaries. Use `confluence-full-context-retrieval` for long pages.
- If the complete updated page body cannot be reconstructed and sent safely, refuse remote write-back.

## Local Workspace Layout

Use this layout for each page:

```text
~/confluence-docs/
  pages/
    <space-key>/
      <page-id-or-slug>/
        manifest.json
        source.md
        draft.md
        notes.md
        chunks/
```

`manifest.json` should track at least:

```json
{
  "pageId": "123456",
  "spaceKey": "ABC",
  "title": "Design Doc",
  "url": "https://example.atlassian.net/wiki/spaces/ABC/pages/123456",
  "version": 42,
  "representation": "markdown-or-storage",
  "fetchedAt": "2026-05-27T00:00:00Z"
}
```

## Workflow

### Phase 1: Resolve and retrieve

1. Resolve the page from URL, page ID, or title.
2. Retrieve metadata first:
   - page ID
   - title
   - URL
   - space key
   - parent ID if available
   - current version
   - available body representation
   - heading outline
3. If the page is large, use `confluence-full-context-retrieval`:
   - outline first
   - bounded heading chunks
   - coverage verification
4. Do not begin remote mutation during retrieval.

### Phase 2: Create local baseline and draft

1. Create the page workspace under `~/confluence-docs/pages/<space-key>/<page-id-or-slug>/`.
2. Save exact retrieved chunks under `chunks/` when chunking was needed.
3. Assemble the complete fetched document into `source.md`.
4. Copy `source.md` to `draft.md` before editing.
5. Write `manifest.json` with page metadata and fetched version.
6. Preserve `source.md` as immutable baseline for the current edit session.

### Phase 3: Edit locally

1. Apply requested changes only to `draft.md`.
2. Keep edits focused and preserve unrelated content.
3. If a requested change depends on omitted or missing page sections, retrieve those sections before editing.
4. Do not summarize sections unless the user explicitly asked for summary replacement.

### Phase 4: Review diff

Open Neovim diff by default:

```bash
nvim -d source.md draft.md
```

If `nvim` is unavailable or the environment cannot open it, fall back to:

```bash
git diff --no-index -- source.md draft.md
```

After diff review:

- State that closing Neovim is not approval.
- Ask the user to type exactly `APPLY` if they want the draft written back to Confluence.
- If the user uses any other phrase, continue in draft mode or ask for exact confirmation.

### Phase 5: Apply only after exact approval

Only after the user writes exactly `APPLY`:

1. Re-fetch page metadata.
2. Compare latest remote version to `manifest.json`.
3. If the version changed, stop and report a conflict. Do not overwrite unless the user asks for a conflict-resolution pass and later writes `APPLY` again.
4. Confirm `draft.md` is a complete document, not a partial section.
5. Update Confluence with the complete updated document body.
6. Never send only edited sections as the replacement page body.

### Phase 6: Verify

After remote update:

1. Re-fetch metadata and verify version incremented.
2. Verify page title and outline still match expectations.
3. Verify the requested edited sections are present.
4. Report exactly what changed and any verification gaps.

## Output Contract

For draft/edit tasks, return:

- page ID, title, URL, and source version
- local workspace path
- files created or edited
- diff review command used
- remote mutation status: none, applied, refused, or blocked
- verification result when applied
- exact next action needed from the user if waiting for approval

## Guardrails

- Do not mutate Confluence without exact `APPLY`.
- Do not claim a full document was retrieved until coverage verification passes.
- Do not overwrite a page when remote version differs from the local manifest.
- Do not write back if body representation or Markdown conversion would discard unsupported content silently.
- Do not use local Git history as the canonical source; Confluence remains canonical unless the user explicitly changes that policy.
