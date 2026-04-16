---
description: Automated Jekyll frontmatter quality checker that finds and fixes unsupported characters and AsciiDoc notation
on:
  schedule:
    - cron: '0 9 * * 1'  # Weekly on Mondays at 9am UTC
  workflow_dispatch:
    inputs:
      file_filter:
        description: 'Optional: filter to specific files (glob pattern)'
        required: false
        type: string
permissions:
  contents: write
  pull-requests: write
timeout-minutes: 30
network:
  allowed:
    - python
    - github
steps:
  - name: Checkout repository
    uses: actions/checkout@v4
    with:
      fetch-depth: 0
      persist-credentials: false
  
  - name: Scan frontmatter for quality issues
    id: scan
    run: |
      echo "# Frontmatter Quality Scan Results" > /tmp/frontmatter-results.md
      echo "" >> /tmp/frontmatter-results.md
      
      # Character validation rules
      DISALLOWED='!@#$%&*()+=[]{}|\\:;,<>?/'
      
      # Find all .adoc files (excluding includes and redirects)
      echo "Scanning .adoc files for frontmatter issues..."
      ADOC_FILES=$(find . -type f -name "*.adoc" \
        ! -path "./_include/*" \
        ! -path "./redirect/*" \
        ! -name "_*" \
        ${{ inputs.file_filter && format('! -path "./{0}"', inputs.file_filter) || '' }})
      
      if [ -z "$ADOC_FILES" ]; then
        echo "No .adoc files found"
        echo "no_files=true" >> $GITHUB_OUTPUT
        exit 0
      fi
      
      # Initialize results
      ISSUE_COUNT=0
      TOTAL_COUNT=0
      
      # Process each file
      for file in $ADOC_FILES; do
        TOTAL_COUNT=$((TOTAL_COUNT + 1))
        
        # Extract frontmatter (between first two ---)
        FM=$(awk '/^---$/{i++; next} i==1' "$file" 2>/dev/null)
        
        if [ -z "$FM" ]; then
          continue
        fi
        
        # Extract fields
        TITLE=$(echo "$FM" | grep "^title:" | sed 's/^title: *//' | tr -d '"')
        KEYWORDS=$(echo "$FM" | grep "^keywords:" | sed 's/^keywords: *//')
        SUMMARY=$(echo "$FM" | grep "^summary:" | sed 's/^summary: *//' | tr -d '"')
        
        FILE_ISSUES=""
        
        # Check title for disallowed characters
        if [ -n "$TITLE" ]; then
          for ((i=0; i<${#DISALLOWED}; i++)); do
            char="${DISALLOWED:$i:1}"
            if [[ "$TITLE" == *"$char"* ]]; then
              FILE_ISSUES="$FILE_ISSUES\n  - title: disallowed char '$char'"
            fi
          done
        fi
        
        # Check keywords for disallowed characters (except comma)
        if [ -n "$KEYWORDS" ]; then
          for ((i=0; i<${#DISALLOWED}; i++)); do
            char="${DISALLOWED:$i:1}"
            [[ "$char" == "," ]] && continue  # Commas allowed in keywords
            if [[ "$KEYWORDS" == *"$char"* ]]; then
              FILE_ISSUES="$FILE_ISSUES\n  - keywords: disallowed char '$char'"
            fi
          done
        fi
        
        # Check summary for disallowed characters and AsciiDoc markup
        if [ -n "$SUMMARY" ]; then
          # Check for ampersand specifically
          if [[ "$SUMMARY" == *"&"* ]]; then
            FILE_ISSUES="$FILE_ISSUES\n  - summary: contains '&' (replace with 'and')"
          fi
          
          # Check for other disallowed (except quotes, commas, forward slash)
          for ((i=0; i<${#DISALLOWED}; i++)); do
            char="${DISALLOWED:$i:1}"
            [[ "$char" =~ [,/\'\"] ]] && continue  # These allowed in summary
            [[ "$char" == "&" ]] && continue  # Already checked
            if [[ "$SUMMARY" == *"$char"* ]]; then
              FILE_ISSUES="$FILE_ISSUES\n  - summary: disallowed char '$char'"
            fi
          done
          
          # Check for AsciiDoc markup
          if [[ "$SUMMARY" =~ \*\*[^*]+\*\* ]]; then
            FILE_ISSUES="$FILE_ISSUES\n  - summary: contains bold markup (**text**)"
          fi
          if [[ "$SUMMARY" =~ \`[^\`]+\` ]]; then
            FILE_ISSUES="$FILE_ISSUES\n  - summary: contains monospace markup (\`text\`)"
          fi
          if [[ "$SUMMARY" =~ _[^_]+_ ]]; then
            FILE_ISSUES="$FILE_ISSUES\n  - summary: contains italic markup (_text_)"
          fi
        fi
        
        # Record issues if found
        if [ -n "$FILE_ISSUES" ]; then
          ISSUE_COUNT=$((ISSUE_COUNT + 1))
          echo "- **$file**" >> /tmp/frontmatter-results.md
          echo -e "$FILE_ISSUES" >> /tmp/frontmatter-results.md
          echo "" >> /tmp/frontmatter-results.md
        fi
      done
      
      # Write summary
      echo "" >> /tmp/frontmatter-results.md
      echo "---" >> /tmp/frontmatter-results.md
      echo "**Scanned:** $TOTAL_COUNT files" >> /tmp/frontmatter-results.md
      echo "**Issues found:** $ISSUE_COUNT files" >> /tmp/frontmatter-results.md
      
      # Output results
      echo "issue_count=$ISSUE_COUNT" >> $GITHUB_OUTPUT
      echo "total_count=$TOTAL_COUNT" >> $GITHUB_OUTPUT
      
      if [ $ISSUE_COUNT -gt 0 ]; then
        echo "has_issues=true" >> $GITHUB_OUTPUT
      else
        echo "has_issues=false" >> $GITHUB_OUTPUT
      fi
      
      cat /tmp/frontmatter-results.md
    shell: bash

tools:
  github:
    toolsets: [default]
  cache-memory: true

safe-outputs:
  create-pull-request:
    title-prefix: "[frontmatter] "
    labels: [documentation, automated, frontmatter-quality]
    draft: false
    protected-files: fallback-to-issue
    if-no-changes: "warn"
  noop:

---

# Frontmatter Quality Checker & Fixer

You are an automated frontmatter quality checker and fixer agent. Your job is to find and fix unsupported characters and AsciiDoc notation in Jekyll frontmatter fields (`title`, `keywords`, `summary`) in AsciiDoc documentation files.

## Your Mission

Your workflow has already scanned all `.adoc` files and identified frontmatter quality issues. Use the scan results to fix these issues where possible, following NetApp documentation standards.

## Step 1: Review Scan Results

The scan step has already run and created a report at `/tmp/frontmatter-results.md`. Read this file to see:
- All files with frontmatter issues
- Which fields have problems (title, keywords, summary)
- What specific issues were found (disallowed characters, AsciiDoc markup)

Use bash to read the file:
```bash
cat /tmp/frontmatter-results.md
```

## Step 2: Load Cache Memory

Check cache memory for context about previous runs:
- Load the cache memory to see if there are any files we've fixed before
- Check for patterns or files that required manual intervention
- This helps avoid repeating the same approach if it didn't work

The cache memory should store a JSON object with this structure:
```json
{
  "manual_intervention_needed": [
    {
      "file": "path/to/file.adoc",
      "reason": "Complex nested markup requires human review",
      "first_seen": "2026-04-16"
    }
  ],
  "last_run": "2026-04-16",
  "files_fixed_count": 45
}
```

## Step 3: Character & Markup Rules

Follow these rules when fixing frontmatter:

**Disallowed characters:** `! @ # $ % & * ( ) + = [ ] { } | \ : ; , < > ? /`

**Exceptions:**
- `summary`: allows `" ' , /`
- `keywords`: allows `,` (delimiter)

**Fix actions:**

| Character/Pattern | title | keywords | summary |
|-------------------|-------|----------|---------|
| `&` | Replace with " and " | Replace with " and " | Replace with " and " |
| `: ; ! @ # $ % * ( ) + = [ ] { } \| \ < > ?` | Remove, collapse whitespace | Remove, collapse whitespace | Remove, collapse whitespace |
| `/` | Remove, collapse whitespace | Remove, collapse whitespace | **Allow** (no change) |
| `,` | Remove, collapse whitespace | **Allow** (no change) | **Allow** (no change) |
| `" '` (quotes) | Remove, collapse whitespace | Remove, collapse whitespace | **Allow** (no change) |
| `**text**` `*text*` (bold) | N/A | N/A | Strip markup, keep text |
| `_text_` `__text__` (italic) | N/A | N/A | Strip markup, keep text |
| `` `text` `` (monospace) | N/A | N/A | Strip markup, keep text |

## Step 4: Fix Each File

Process files in batches of 10. For each file with issues:

### A. Read the file and extract frontmatter

Read the first 50 lines of the file. Extract content between the first two `---` markers to get the Jekyll frontmatter block.

```bash
head -n 50 path/to/file.adoc
```

### B. Determine fix strategy

**For simple fixes** (single character replacement, e.g., `&` → `and`):
- Apply the fix directly to the existing field value

**For summary with complex markup** (3+ markup elements, nested formatting, or >30% markup characters):
- Search for the `[.lead]` paragraph in the file (typically lines 10-30)
- Extract the paragraph after `[.lead]` (ends at next blank line)
- Strip AsciiDoc notation from the lead text
- Use this as the replacement summary value

Example of finding lead:
```bash
grep -A 10 "^\[\.lead\]" path/to/file.adoc | head -n 10
```

### C. Apply the fix

Use the `edit` tool to update the frontmatter field. Replace only the affected field line(s), preserving YAML syntax:

**Important:**
- Maintain YAML quote syntax for summary: `summary: "text here"`
- Keep keywords unquoted: `keywords: word1, word2, word3`
- Collapse multiple spaces to single space after removing characters
- Trim leading/trailing whitespace

### D. Document complex cases

If a file has issues that are difficult to fix programmatically:
- **Nested complex markup** in summary with no clear lead paragraph
- **Special characters** that might be intentional (e.g., code examples)
- **Context-dependent decisions** that need human judgment

Add these to the `manual_intervention_needed` list in cache memory with a clear reason.

## Step 5: Update Cache Memory

After processing all files:
- Update cache memory with any new manual intervention cases
- Update the "last_run" timestamp
- Increment "files_fixed_count" with the number of files you successfully fixed
- Save the updated cache memory

## Step 6: Create Pull Request or Noop

Based on your work:

**If you fixed any files:**
- Use the `create-pull-request` safe output to create a PR with your fixes
- In the PR body, include:
  - Summary: "Fixed frontmatter quality issues in X files"
  - Table of fixed files with issue counts
  - List any files added to manual intervention list
- Title format: "Fix frontmatter quality issues in documentation"
- Set labels: `documentation`, `automated`, `frontmatter-quality`

**If no files needed fixing:**
- Use the `noop` safe output with message:
  - "All frontmatter fields are compliant with quality standards" (if no issues found)
  - "All identified issues require manual intervention" (if issues exist but can't be auto-fixed)

## Important Guidelines

- **Process in batches:** Fix 10 files at a time, then write to cache before continuing
- **Preserve meaning:** When replacing `&`, ensure "and" makes sense in context
- **Use lead when appropriate:** Don't force lead usage for simple character fixes
- **Maintain YAML syntax:** Don't break the Jekyll frontmatter structure
- **Be selective about manual intervention:** Only flag truly complex cases
- **Validate after each fix:** Re-read the file to confirm the change is correct
- **Follow NetApp conventions:** Summaries should be clear, concise, single paragraphs

## Example Cache Memory Update

```json
{
  "manual_intervention_needed": [
    {
      "file": "switch-cisco-9336c-fx2/install-nxos.adoc",
      "reason": "Summary has nested markup with inline code and bold that requires careful review",
      "first_seen": "2026-04-16"
    }
  ],
  "last_run": "2026-04-16",
  "files_fixed_count": 47
}
```

## Context

- Repository: `${{ github.repository }}`
- Run weekly on Mondays (or manually via workflow_dispatch)
- Scan results are available at `/tmp/frontmatter-results.md`
- Focus on `.adoc` files only (exclude `_include/`, `redirect/`, and files starting with `_`)
