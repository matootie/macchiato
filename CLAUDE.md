# CLAUDE.md

> **Every code change must follow the Development Rules (R1–R10) and the Engineering Principles. Read them before starting any task.**

## What is this project?

Macchiato is a lightweight macOS app that lives in the menu bar. It's entire purpose is to easily toggle use of the internal command `caffeinate`. I find myself frequently opening up a terminal and leaving it open with `caffeinate -ds`, but it gets annoying having this window ever-present, especially when i'm working with other terminal windows. It gets in the way. For that reason, Macchiato will run `caffeinate -ds` with an easy menu bar toggle.

## Development rules

### R1 — Search before you fix

When making a change that applies a pattern across multiple locations, grep the entire codebase first. List all instances. Fix all of them. Re-run the same grep and confirm zero remaining unfixed instances.

### R2 — Verify the wiring

Don't just write a module — prove it's called in production. Trace the path: route registered? middleware applied? component rendered? CDK stack included?

### R3 — Check the siblings

Before modifying a route handler, middleware, or component, find its siblings — same directory, same pattern. Verify your change is consistent.

### R4 — Test the feature, not the defaults

Every new parameter, branch, or code path needs at least one test with a real, non-default value.

### R5 — Types at boundaries

Any value crossing a module boundary must have an explicit type.

### R6 — Self-check before declaring done

1. Did I search for all instances? (R1)
2. Is my code wired into the app? (R2)
3. Are sibling functions consistent? (R3)
4. Did I test the actual feature? (R4)
5. Are types explicit at boundaries? (R5)
6. Does pre-existing behavior still work? (unit tests)

### R7 — Fix what's asked, nothing else

Stay in scope. If you notice unrelated issues, flag them — don't fix them.

### R8 — Prove it works beyond tests

For UI changes, verify in the simulator. For API changes, curl the endpoint. Tests alone aren't enough.

### R9 — Commit everything before reporting done

No uncommitted changes. `git status` should be clean.

### R10 — Trace the full chain before writing a fix

Before changing code, trace the data flow from entry point to the problem. Understand why, not just where.

## Engineering principles

Write code as a senior engineer would: correct, readable, tested, and minimal.

### Core priorities (in order)

1. **Correctness first.** Code must do what it claims to do. Verify with tests. Verify edge cases. Verify error paths.
2. **Readability second.** Code is read far more than it is written. Use clear names, logical structure, and obvious flow. If a reader needs a comment to understand what code does, the code should probably be rewritten. Reserve comments for _why_, not _what_.
3. **Minimalism third (YAGNI).** Do not build for hypothetical future requirements. Implement exactly what the current task needs. No speculative abstractions, no "just in case" parameters, no premature generalization. Three concrete uses before extracting a shared utility.

### Practices

- **DRY (Don't Repeat Yourself).** Duplication of _knowledge_ is the enemy, not duplication of code. If two blocks of code look similar but represent different concepts, they should stay separate. If they represent the same concept, extract a shared function after the third occurrence.
- **Single Responsibility.** Each module, class, and function does one thing. A route handler validates input, calls a service, and returns a response. A service implements business logic. A repository handles data access. Do not mix these.
- **Fail fast, fail loud.** If something is wrong, raise an error immediately with a clear message. Do not silently swallow errors or return partial results. Catch exceptions at the boundary (middleware, top-level handler), not at every level.
- **Explicit error handling at boundaries.** Validate inputs at system boundaries (HTTP request handlers, message consumers, external API responses). Internal functions may trust their callers. Do not add defensive checks deep in call stacks where the data has already been validated upstream.
- **Type safety.** Swift uses explicit types at public interfaces.
- **No dead code.** Do not leave commented-out code, unused imports, unreachable branches, or placeholder functions. If code is not needed now, delete it.

## Documentation standards

Documentation is part of the definition of done. A feature, endpoint, or component is not complete until it is documented.

1. **Every deliverable gets a docs update.** If you built it, document it. New API endpoints, new features, new components, changed behavior — all require documentation.
2. **Write for the reader, not yourself.** Assume the reader is a developer who has just joined the team. They are competent but unfamiliar with this specific system.
3. **Include examples.** Every API endpoint should include at least one realistic request/response example. Every non-trivial function should include a usage example in its docstring.
4. **Docs live with the code.** Write doc comments (Swift) for all public interfaces. These are the source of truth for API reference.
5. **API contracts are documented.** API endpoints must have their request/response shapes, status codes, and error cases defined.

## Quality assurance

### Before writing code

1. **Identify what needs to change.** Read the relevant code. Understand the existing patterns and data flow (R10).
2. **Design the interface first.** For APIs: define the route, request/response shapes, status codes, and error cases. For modules: define the function signatures and types.
3. **Identify test cases.** Happy path, error cases, edge cases.

### While writing code

1. **Write tests alongside implementation.** Every new function, endpoint, or behavior needs a corresponding test. Tests should use real, non-default values (R4).
2. **Commit logically.** Each commit should represent a coherent unit of work, not a WIP dump.

### Before declaring done

1. **Run the full test suite.** All tests must pass. Zero skipped tests.
2. **Verify formatting.**
3. **Verify types.**
4. **Manual verification.** For API changes, curl the endpoint. For UI changes, verify in the simulator. Tests alone aren't enough (R8).
5. **Check for regressions.** If the change touched shared code, verify all affected services still build and pass tests.
6. **Self-review.** Review your own code as if reviewing a pull request from someone else (R6). Check for logic errors, naming clarity, test coverage gaps, DRY violations, and YAGNI violations.
7. **Documentation.** Verify that doc comments are present for all public interfaces, and that any relevant documentation has been updated to reflect the change.

## Pull request policy

- All pull requests must be **neatly assembled**: logically organized commits, clear title and description, and no unrelated changes mixed in.
- PR descriptions must include a **summary of changes** and a **test plan**.
- Keep PRs focused and reviewable — if a deliverable is too large for a single clean PR, split it into coherent slices.

## Git

- Default branch: `trunk`
- Conventional commits: `feat:`, `fix:`, `chore:`, etc.
- No `Co-authored-by` AI trailers

