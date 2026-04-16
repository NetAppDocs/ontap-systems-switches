@ -0,0 +1,161 @@
---
name: Jekyll Front Matter Check Agent
description: Scans NetApp AsciiDoc documentation for unsupported characters in Jekyll front matter and fixes them automatically
tools: ['execute', 'read', 'edit', 'search']
user-invocable: true
---

## Task

Accept a **CQP CSV report** to identify and fix unsupported characters or AsciiDoc notation in Jekyll front matter fields (`title`, `keywords`, `summary`). Process in batches of 10, maintain checkpoint state, report results. Follow the workflow exactly as written.

**Input format:**
- CSV: column 6 (event detail), column 7 (file path)

## Character & Markup Rules

**Disallowed characters:** `! @ # $ % & * ( ) + = [ ] { } | \ : ; , < > ? /`

**Exceptions:**
- `summary`: allows `" ' , /`
- `keywords`: allows `,` (delimiter)

**Fix actions:**

| Character/Pattern | title | keywords | summary |
|-------------------|-------|----------|---------|
| `&` | Replace with " and " | Replace with " and " | Replace with " and " |
| `: ; ! @ # $ % * ( ) + = [ ] { } \| \ < > ?` | Remove, collapse whitespace | Remove, collapse whitespace | Remove, collapse whitespace |
| `/` | Remove, collapse whitespace | Remove, collapse whitespace | **Allow** |
| `,` | Remove, collapse whitespace | **Allow** | **Allow** |
| `" '` (quotes) | Remove, collapse whitespace | Remove, collapse whitespace | **Allow** |
| `**text**` `*text*` (bold) | N/A | N/A | Strip markup, keep text |
| `_text_` `__text__` (italic) | N/A | N/A | Strip markup, keep text |
| `` `text` `` (monospace) | N/A | N/A | Strip markup, keep text |

**Summary rewrite threshold:** If summary has 3+ markup elements, nested formatting, or >30% markup characters, use `[.lead]` paragraph as source instead of cleaning existing text.

## Checkpoint Management

**File:** `_frontmatter-check-state.json` in workspace root

**Critical rules:**
- Write after **every batch** using file tools only (never terminal commands)
- Backup previous state to `_frontmatter-check-state.backup.json` before overwriting
- Validate JSON structure before writing; halt on failure
- Resume: if checkpoint exists, prompt user "Resume from checkpoint? (yes/no)"
- Errors: mark with `"error": "<reason>"` and continue (don't halt run)

**Progress display:** After each batch: `Batch N/M complete: X processed, Y fixed, Z errors`

## JSON Schema

```json
{
  "type": "array",
  "items": {
    "type": "object",
    "properties": {
      "fileName": { "type": "string" },
      "eventDetail": { "type": "string" },
      "hasIssues": { "type": "string", "enum": ["Yes", "No"] },
      "titleIssues": { "type": "array", "items": { "type": "string" } },
      "keywordsIssues": { "type": "array", "items": { "type": "string" } },
      "summaryIssues": { "type": "array", "items": { "type": "string" } },
      "originalTitle": { "type": ["string", "null"] },
      "originalKeywords": { "type": ["string", "null"] },
      "originalSummary": { "type": ["string", "null"] },
      "fixedTitle": { "type": ["string", "null"] },
      "fixedKeywords": { "type": ["string", "null"] },
      "fixedSummary": { "type": ["string", "null"] },
      "fixApplied": { "type": "string", "enum": ["Yes", "No"] },
      "error": { "type": "string" }
    },
    "required": ["fileName", "eventDetail", "hasIssues", "titleIssues", "keywordsIssues", "summaryIssues", "fixApplied"]
  }
}
```

## Workflow

### 1. Extract files from source

1. Ask user for CSV path if not provided
2. Read CSV, skip header row if present, handle quoted fields
3. Extract column 6 (event detail) and column 7 (file path)
4. Build unique `.adoc` file list, exclude: `_*` files, duplicates, non-.adoc
5. Initialize checkpoint with fileName + eventDetail per file
6. Write checkpoint

Display: `Found X .adoc files from CSV. Starting inspection in batches of 10.`

### 2. Process files in batches of 10

For each file:

**A. Extract front matter**
- Read first 50 lines
- Extract content between first two `---` markers
- Get `title`, `keywords`, `summary` field values (preserve YAML quote syntax)
- Note: YAML `title:` field is distinct from AsciiDoc `= Page Title` (many files lack YAML title)

**B. Inspect for issues**
- Check each field against character/markup rules
- Build issue lists (e.g., "Contains `&` at position 42", "Contains AsciiDoc bold `**text**`")

**C. Generate fixes**
- Apply fix actions from rules table
- For summary: if meets rewrite threshold, read `[.lead]` paragraph (typically lines 10-30) and use as source
- Set fixedTitle/Keywords/Summary to corrected values (null if no issues)

**D. Apply changes**
- Use `replace_string_in_file` or `multi_replace_string_in_file` to update front matter fields
- Set `fixApplied: "Yes"` if written, `"No"` if unchanged

**E. Update checkpoint**
- After batch complete, write checkpoint with validation
- Continue to next batch

### 3. Report results

Display full summary:

```
Jekyll Front Matter Check Complete
===================================
CSV Source: [path]
Total files: X | Fixed: Y | No issues: Z | Errors: W

Files Fixed:
- [fileName]: title/keywords/summary changed
  Event: [eventDetail]
  Original summary: [first 80 chars...]
  Fixed summary: [first 80 chars...]

Files with Errors:
- [fileName]: [error reason]
  Event: [eventDetail]
```

Display table of all files with `hasIssues: Yes`:

| File | Title issues | Keywords issues | Summary issues | Fix applied |
|------|-------------|-----------------|----------------|-------------|

### 4. Create PR (optional)

Prompt: "Create a pull request with these fixes? (yes/no)"

**If yes:**
- Branch: `fix/jekyll-frontmatter-YYYYMMDD`
- Commit: `Fix unsupported characters in Jekyll front matter`
- PR title: Same as commit message
- PR body: Summary with file counts and changed files list
- Delete checkpoint files after PR created

**If no:** Remind user checkpoint file remains in workspace root for later review.

**If no:** Remind user checkpoint file remains in workspace root for later review.