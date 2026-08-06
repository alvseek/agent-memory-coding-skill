# Code Quality Analysis

## **ANALYSIS INFO**
- **Project**: [Project Name]
- **Date**: [YYYY-MM-DD]
- **Agent**: [Agent Name]
- **Scope**: [What is being reviewed — files, feature, milestone]
- **Quality Standard**: [Path to quality-standard.md if found, or "None — freeform analysis"]
- **Source Protocol**: `/analyze-code-quality` — /analyze-code-quality

*CRITICAL INSTRUCTION: To continue this plan: load the source protocol above, then inspect which sections below are filled vs unfilled to infer your current step.*

---

## **QUALITY DIMENSIONS**

*Walk through each dimension. Skip dimensions that don't apply to the scope. Check items are guidelines — use judgment to identify issues beyond the listed checks.*

### 1. Error Handling
*Does the code handle failure gracefully?*

- [ ] External calls (API, database, file I/O) have try/catch or error handling
- [ ] Error responses return meaningful messages (not generic 500 or silent failures)
- [ ] Errors are propagated correctly to callers (not swallowed)
- [ ] Network errors, timeouts, and edge cases are handled
- [ ] User-facing error messages are helpful (not stack traces or technical jargon)
- [ ] Retry logic exists where appropriate (transient failures)

### 2. State Completeness
*Does every data-dependent UI element handle all possible states?*

- [ ] Loading states for async operations (spinners, skeletons, disabled buttons)
- [ ] Empty states for collections, lists, tables (not blank screens)
- [ ] Error states for failed data fetches (error message, retry option)
- [ ] Disabled states during form submission or async actions (prevent double-submit)
- [ ] Optimistic updates revert correctly on failure
- [ ] Stale data is handled (cache invalidation, refetch triggers)

### 3. UX Completeness
*Does every user interaction have a complete flow?*

- [ ] Every open/show action has a corresponding close/dismiss/cancel
- [ ] Every destructive action has confirmation (delete, remove, overwrite)
- [ ] Every user action has feedback (success toast, error message, visual change)
- [ ] Form validation is present with clear error messages
- [ ] Navigation flows are complete (back buttons, breadcrumbs, redirect after action)
- [ ] Keyboard accessibility for interactive elements (Enter to submit, Escape to close)
- [ ] Focus management after modals, drawers, or dynamic content

### 4. Efficiency
*Does the code avoid unnecessary work?*

- [ ] No redundant API calls (same data fetched multiple times in component tree)
- [ ] No unnecessary re-renders (missing memoization, unstable references)
- [ ] No N+1 query patterns (database queries inside loops)
- [ ] Expensive operations are debounced/throttled where appropriate (search, resize, scroll)
- [ ] Large lists use virtualization or pagination
- [ ] Assets are optimized (images, bundle size, lazy loading)

### 5. Security
*Does the code protect against common vulnerabilities?*

- [ ] User input is sanitized before rendering (XSS prevention)
- [ ] SQL/NoSQL queries use parameterized queries (injection prevention)
- [ ] Authentication checks on protected routes/endpoints
- [ ] Authorization checks — users can only access their own resources
- [ ] Sensitive data not exposed in responses, logs, or client-side code
- [ ] CORS, CSRF, and rate limiting configured where applicable
- [ ] File uploads validated (type, size, content)

### 6. Cleanup
*Is the code free of development artifacts?*

- [ ] No console.log / print statements left in production code
- [ ] No commented-out code blocks (delete it, git has history)
- [ ] No hardcoded values that should be constants or environment variables
- [ ] No TODO/FIXME/HACK comments left unresolved
- [ ] No unused imports, variables, or functions
- [ ] No placeholder text or dummy data in production paths

### 7. Consistency
*Does the code follow the patterns established in the codebase?*

- [ ] Naming conventions match the rest of the codebase (camelCase, snake_case, etc.)
- [ ] File/folder structure follows project conventions
- [ ] Error handling patterns match existing code (centralized handler vs inline)
- [ ] API response format matches existing endpoints
- [ ] Component/module patterns match existing code (hooks, services, utilities)
- [ ] Code style consistent (formatting, indentation — should be handled by linter but check)

### 8. Project Quality Standard Compliance
*Only if a quality-standard.md was found — check against project-specific criteria.*

- [ ] [Check against each criterion defined in the project's quality-standard.md]

---

## **FINDINGS**

*Document each finding with severity, location, and fix options.*

| # | Severity | File:Line | Issue | Fix Options |
|---|----------|-----------|-------|-------------|
| 1 | Critical/Medium/Low | [path:line] | [Description of the issue] | A) [Fix] B) [Alternative] |
| 2 | | | | |

---

## **WAIT OPTIONS**

*Present findings grouped by severity for [USER-NAME] to decide.*

```
Code quality review for [scope]:

**Critical:**
1. [File:line] [Issue]:  [A) Fix ✓✓]  B) Alternative  (why this matters)

**Medium:**
2. [File:line] [Issue]:  [A) Fix ✓✓]  B) Alternative  (why this matters)

**Low:**
3. [File:line] [Issue]:  [A) Fix ✓✓]  B) Skip  (minor polish)

**Summary**: X critical, Y medium, Z low

Reply with changes (e.g., "skip 3", "change 1 to B") or "fix all" to accept defaults, or "ship it" to skip all.
```

---

## **RESOLUTION LOG**

| # | Decision | Action Taken |
|---|----------|-------------|
| 1 | [Approved / Skipped] | [What was done] |
| 2 | | |

---
