# Agent Instructions

These are shared instructions that apply across all AI coding agents (Claude Code, OpenCode, etc.).

## General Principles

- Read and understand existing code before suggesting modifications
- Prefer editing existing files over creating new ones
- Keep changes focused and minimal — only modify what is directly needed
- Do not add unnecessary abstractions, error handling, or comments
- Avoid over-engineering: three similar lines is better than a premature abstraction

## Code Style

- Follow the conventions already established in the project
- Match the existing indentation, naming, and formatting patterns
- Only add comments where the logic is not self-evident
- Do not add docstrings or type annotations to code you did not change

## Git Practices

- Write concise commit messages that explain the "why", not the "what"
- Never force push or run destructive git operations without explicit confirmation
- Prefer creating new commits over amending existing ones
- Stage specific files rather than using `git add .`

## Safety

- Never commit files containing secrets (`.env`, credentials, tokens)
- Avoid introducing common vulnerabilities (injection, XSS, SSRF)
- Do not skip pre-commit hooks or bypass safety checks
- Confirm before taking actions that affect shared systems (push, deploy, post)

## Communication

- Be concise — lead with the answer, not the reasoning
- Skip filler, preamble, and restating what was asked
- Only surface decisions that need input, status at milestones, or blockers

## Tool Usage

- Use dedicated tools (read, edit, grep, glob) over shell equivalents when available
- Parallelize independent operations where possible
- When searching broadly, use exploration agents; for targeted lookups, use grep/glob directly
