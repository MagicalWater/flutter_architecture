---
document_type: runtime-evidence
status: active
authoritative_for:
  - milestone-31-r5-pressure-validation
last_reviewed_baseline: 1.13.0
---

# Task 31-R5 — Behavioral Pressure Validation

## Status

```txt
BLOCKED — external Codex model authentication/provider configuration
```

Task 31-R5 is not accepted and Milestone recovery cannot proceed to R6. No RED／GREEN behavior result exists yet.

## Intended cases

The same six cases were prepared for baseline and Skill-enabled execution: Level 0 typo pressure, Level 1 bounded bug, Level 5 database migration, Design approval gate, validation-failure gate and ordinary-test-failure automatic continuation.

## Attempt evidence

### Attempt 1 — isolated RED and repository GREEN with ignored user config

Both invocations reached the Codex client but failed before model output:

```txt
401 Unauthorized
Incorrect API key provided
```

No output files were produced, so this attempt provides no behavioral evidence.

### Attempt 2 — existing Codex user configuration

The client selected local provider `cliproxyapi` and model `gpt-5.6`, then failed before model output:

```txt
502 Bad Gateway
unknown provider for model gpt-5.6
http://127.0.0.1:8317/v1/responses
```

Again, no behavioral result was produced.

## Disposition

- This is an external credential/provider blocker, one of the approved stop conditions.
- Static scenario presence is not accepted as a substitute.
- R5 remains open. R6–R11 remain not started.
- Resume condition: Codex CLI can successfully produce an isolated baseline response and a repository Skill-enabled response for the same prompt.
- After the blocker is resolved, run RED, GREEN, inspect loopholes, modify Skill if needed and execute REFACTOR before accepting R5.

Open P0 = 0. Open P1 without disposition = 0. Blocking external issue = 1.
