# Load Project Context Protocol

Load project-specific context files from **both** the per-agent layer (`agent-[domain]/knowledge-base/[project]/`) and the shared layer (`shared-memory/[project]/context/`) into working memory. Supports listing all available context or loading specific files by keyword. Entries are presented with `[shared]` / `[private]` markers so the source layer is always visible.

## Arguments

`$ARGUMENTS`

- `/load-project-context` → List all project context files (both layers) with numbers, user selects which to load
- `/load-project-context [keyword]` → Auto-match files by keyword against tags and file names across both layers, load matches directly. Falls back to list mode if no match found

---

## Procedure

*IMPORTANT: Use TodoWrite tool with FULL VERBATIM copy of each step below (including all commands, examples, and sub-points) to prevent context loss and ensure complete execution*

### Step 1: Scan Available Project Context

Scan **both** locations for project context files:

1. **Per-agent (private) layer**: Scan `[AGENT-MEMORY-PATH]/agent-[domain]/knowledge-base/` for project subfolders (exclude `research/` folder — that's domain knowledge, not project context). For each project subfolder, read its `context-index.md`.

2. **Shared layer**: Scan `[AGENT-MEMORY-PATH]/shared-memory/` for project subfolders. For each project subfolder, check if `context/context-index.md` exists, and if so read it.

> **Storage location (localized-home resolution)**: apply `/localize-context`'s Localized Home Resolution per project. For a **localized** project (central map `home: project`) → read shared from `<project-root>/docs/`, private from `<project-root>/.agents/knowledge/`; otherwise read the central `shared-memory/[project]/context/` + `agent-[domain]/knowledge-base/[project]/` locations above. (Scope markers `[shared]`/`[private]` unchanged.)

**Silent skip**: If either folder is missing or empty for a given project, skip it without error. Only present what exists.

For each entry found, retain its **scope marker**:
- Entry from `agent-[domain]/knowledge-base/[project]/` → marker `[private]`
- Entry from `shared-memory/[project]/context/` → marker `[shared]`

If no context files are found in either layer, inform the user: "No project context files found. Use `/update-project-context` to create your first one."

### Step 2: Parse Arguments

Check if arguments were provided:
- **No arguments**: Go to Step 3 (List Mode)
- **Arguments provided**: Go to Step 4 (Match Mode)

### Step 3: List Mode

Present all project context files as a numbered list grouped by project, with the scope marker prefixed on each entry:

**Format:**
```
Project context files available:

[project-name-1]
  1. [shared] [theme].md — [description] (tags: tag1, tag2)
  2. [private] [theme].md — [description] (tags: tag1, tag2)

[project-name-2]
  3. [shared] [theme].md — [description] (tags: tag1, tag2)
  4. [private] [theme].md — [description] (tags: tag1, tag2)

Enter number(s) to load (e.g., "1", "1,3", "all"), or "cancel":
```

If a project has entries in only one layer, only that layer's entries are listed (no empty "shared" or "private" sub-list).

Wait for user selection, then go to Step 5.

### Step 4: Match Mode

Search for the keyword(s) from arguments across **both layers** against:
1. **Tags**: Match against `tags: [...]` in YAML frontmatter
2. **File names**: Match against the file name (e.g., keyword "deploy" matches `deployment.md`)
3. **Project names**: Match against project folder names

**If matches found**: Show what will be loaded and proceed to Step 5:
```
Found [N] matching context file(s) for "[keyword]":
  1. [shared] [project]/[theme].md — [description]
  2. [private] [project]/[theme].md — [description]

Loading...
```

**If no matches found**: Inform the user and fall back to Step 3 (List Mode):
```
No context files matching "[keyword]" found. Showing all available:
```

### Step 5: Load Selected Files

Read the selected file(s) into agent context using the Read tool from their source-layer path:
- Shared entries: `[AGENT-MEMORY-PATH]/shared-memory/[project]/context/[theme].md`
- Private entries: `[AGENT-MEMORY-PATH]/agent-[domain]/knowledge-base/[project]/[theme].md`

After loading, confirm to the user with the scope marker for each file:
```
Loaded [N] project context file(s):
  - [shared] [project]/[theme].md (tags: tag1, tag2)
  - [private] [project]/[theme].md (tags: tag1, tag2)
```

---
