# Language Patterns

Use this file for language-specific coding patterns.

## Python

### Naming

- Use `snake_case` for functions and variables.
- Use `CapWords` for classes.
- Avoid unclear abbreviations unless they are standard.

### Exceptions

- Raise specific exception types.
- Keep exception messages actionable.
- Avoid broad `except Exception` without re-raising.

### Types and Data Shapes

- Keep data shapes explicit at module boundaries.
- Normalize external input before business logic.
- Avoid passing loosely shaped dictionaries through many layers.

### Functions

- Keep functions focused on one responsibility.
- Return consistent types.
- Avoid mixing I/O, parsing, and business rules in one long function.

### Imports and Dependencies

- Prefer standard library first.
- Keep imports grouped and sorted per project style.
- Avoid adding new dependencies for simple utility needs.

### Tests

- Name tests by behavior.
- Use fixtures for shared setup.
- Avoid sleep-based tests when deterministic alternatives exist.
