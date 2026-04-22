# Documentation Classification Rubric

Use this rubric before adding or moving any document in `.config/ai/docs`.

## Quick Decision

- Put it in `policies/` when it defines rules that should always apply.
- Put it in `runbooks/` when it explains how to execute or recover from a specific scenario.
- Put it in `references/` when it is lookup material, schema details, or mapping examples.

## Decision Table

| Signal | policies | runbooks | references |
| --- | --- | --- | --- |
| Primary question answered | What must/should always be true? | How do I do or repair this? | Where can I look this up? |
| Writing style | Normative (`must`, `should`, `never`) | Sequential steps with verification | Factual definitions, examples, mappings |
| Typical structure | Rules + guardrails + exceptions | Preconditions, steps, checks, rollback | Field reference, glossary, examples |
| Change cadence | Low | Medium | Medium to high |

## Anti-Patterns

- Policy doc with command-by-command procedures.
- Runbook with broad philosophy and no executable steps.
- Reference doc that contains imperative instructions.

## Tie-Breakers

- If the document includes a numbered command sequence and verification, it is a runbook.
- If the document uses RFC-style requirement language and no command sequence, it is a policy.
- If the document can be consumed out of order as a lookup artifact, it is a reference.
