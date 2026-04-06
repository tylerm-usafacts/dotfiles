# Language Patterns

Use this file for language-specific coding patterns.

## Python

### Naming

- Do: use `snake_case` for functions and variables.
- Do: use `CapWords` for classes.
- Avoid: unclear abbreviations unless they are standard.

Example:

- Prefer `calculate_total_price` over `calc_tp`.

### Exceptions

- Do: raise specific exception types.
- Do: keep exception messages actionable.
- Avoid: broad `except Exception` without re-raising.

Example:

- Prefer `except ValueError as err:` over `except Exception:`.

### Types and Data Shapes

- Do: keep data shapes explicit at module boundaries.
- Do: normalize external input before business logic.
- Avoid: passing loosely shaped dictionaries through many layers.

Example:

- Parse request payload once, then pass a validated object onward.

### Functions

- Do: keep functions focused on one responsibility.
- Do: return consistent types.
- Avoid: mixing I/O, parsing, and business rules in one long function.

Example:

- Split `load_and_process_orders` into read, validate, and process steps.

### Imports and Dependencies

- Do: prefer standard library first.
- Do: keep imports grouped and sorted per project style.
- Avoid: adding new dependencies for simple utility needs.

Example:

- Use `pathlib` for path handling before adding a helper package.

### Tests

- Do: name tests by behavior.
- Do: use fixtures for shared setup.
- Avoid: sleep-based tests when deterministic alternatives exist.

Example:

- Prefer `test_rejects_empty_email` over `test_email_validation_case_1`.

Add new items only when they are broadly useful across projects, not tied to a single codebase.
