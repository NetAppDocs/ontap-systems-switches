# Jekyll Frontmatter Quality Tools

Tools for detecting and fixing invalid characters in Jekyll frontmatter fields (`title`, `keywords`, `summary`).

## Agentic Workflow

Following the [GitHub agentics pattern](https://github.com/githubnext/agentics), the frontmatter quality check is implemented as a **single workflow file** that contains both the deterministic detection logic and the intelligent agent instructions.

**File:** `.github/workflows/frontmatter-checker.md`

### How It Works

```
┌─────────────────────────────────────────────────────────┐
│  frontmatter-checker.md                                 │
├─────────────────────────────────────────────────────────┤
│  YAML Front Matter (GitHub Actions)                     │
│  ┌────────────────────────────────────────────┐        │
│  │ - Trigger: weekly schedule / manual        │        │
│  │ - Steps: Bash script scans .adoc files     │        │
│  │ - Output: /tmp/frontmatter-results.md      │        │
│  │ - Tools: github, cache-memory              │        │
│  └────────────────────────────────────────────┘        │
│                                                          │
│  ---                                                     │
│                                                          │
│  Agent Instructions (Markdown)                           │
│  ┌────────────────────────────────────────────┐        │
│  │ 1. Read scan results                       │        │
│  │ 2. Load cache memory                       │        │
│  │ 3. Apply character & markup rules          │        │
│  │ 4. Fix files intelligently                 │        │
│  │ 5. Update cache                            │        │
│  │ 6. Create PR or noop                       │        │
│  └────────────────────────────────────────────┘        │
└─────────────────────────────────────────────────────────┘
```

### Two Workflows

### 🔄 Reactive (Writer-Initiated)

Writer receives a CQP report and uses the standalone agent to fix their files.

**Steps:**
1. Receive CQP CSV report identifying frontmatter issues
2. Run standalone agent: `@jekyll-frontmatter-check-agent`
3. Provide CSV file path when prompted
4. Agent scans, fixes, and creates PR

**Files:**
- Agent: `.github/agents/jekyll-frontmatter-check-specialist.md`

**Best for:**
- Individual writers fixing their own files
- On-demand fixes triggered by quality reports
- Files from a specific CQP issue

### ⚙️ Proactive (Automated)

Scheduled agentic workflow scans all files, agent fixes issues, creates PR automatically.

**How it works:**
1. GitHub Actions runs weekly (or manual trigger)
2. Bash script scans all `.adoc` files for issues
3. Generates `/tmp/frontmatter-results.md` 
4. Agent reads results, applies intelligent fixes
5. Agent creates PR with fixes or reports manual intervention needed
6. Uses cache memory to track complex cases across runs

**Files:**
- Agentic workflow: `.github/workflows/frontmatter-checker.md`
- Single file contains: workflow config + detection script + agent instructions

**Best for:**
- Catching issues before they reach CQP
- Regular maintenance scans
- Organization-wide quality checks
- Fully automated fixes with human review via PR

## Components

### Option 1: Agentic Workflow (Recommended)

**File:** `.github/workflows/frontmatter-checker.md`

Single file containing:
- **YAML front matter**: GitHub Actions workflow configuration
  - Scheduled trigger (weekly Monday 9am UTC)
  - Manual trigger via workflow_dispatch
  - Bash-based detection script (inline)
  - Outputs results to `/tmp/frontmatter-results.md`
- **Agent instructions**: Steps for intelligent fixing
  - Read scan results
  - Apply character/markup rules with context
  - Use `[.lead]` paragraph for complex summaries
  - Cache memory for tracking manual intervention cases
  - Create PR with fixes

**Trigger manually:**
- Go to `Actions` tab → select the `frontmatter-checker` workflow → `Run workflow`

**Benefits:**
- ✅ Self-contained (one file)
- ✅ Automated end-to-end (scan → fix → PR)
- ✅ Cache memory for learning across runs
- ✅ Follows GitHub agentics pattern

### Option 2: Standalone Agent

For reactive workflows (writer-initiated fixes from CQP reports):

**File:** `.github/agents/jekyll-frontmatter-check-specialist.md`

Intelligent decision-making for fixes:
- When to use `[.lead]` paragraph vs. cleaning existing summary
- How to handle complex markup
- Edge case handling
- Batch processing with checkpoint/resume

**Accepts input:**
- CSV from CQP: `C:\path\to\report.csv`

**Usage:**
```
@jekyll-frontmatter-check-agent
```
Then provide the path to your CQP CSV file when prompted.

## Usage Examples

### Agentic Workflow: Fully Automated

**Scheduled run:**
1. Workflow runs automatically every Monday at 9am UTC
2. Check `Actions` tab for workflow results
3. If issues found, agent automatically creates PR with fixes
4. Review and merge the PR

**Manual trigger:**
1. Go to `Actions` tab in GitHub
2. Select the `frontmatter-checker` workflow
3. Click "Run workflow"
4. Agent creates PR if fixes were applied

**With file filter:**
```yaml
# In workflow_dispatch inputs
file_filter: "switch-cisco-*/**"
```

### Reactive: Fix files from CQP report

**Using standalone agent:**
```
You: @jekyll-frontmatter-check-agent
Agent: [asks for CSV path]
You: C:\Users\jsnyder\Downloads\cqp_report_12345.csv
Agent: [scans, fixes, creates PR]
```

## Character Rules

| Character | title | keywords | summary |
|-----------|-------|----------|---------|
| `&` | → " and " | → " and " | → " and " |
| `: ; ! @ # $` etc. | ❌ Remove | ❌ Remove | ❌ Remove |
| `/` | ❌ Remove | ❌ Remove | ✅ Allow |
| `,` | ❌ Remove | ✅ Allow | ✅ Allow |
| `" '` | ❌ Remove | ❌ Remove | ✅ Allow |
| `**bold**` | N/A | N/A | Strip to `bold` |

## Permissions

### For Agentic Workflow

The GitHub Actions workflow in `frontmatter-checker.md` requires:
- `contents: write` - to checkout code and allow agent to edit files
- `pull-requests: write` - to create PRs with fixes

**Setup:**
1. Go to repository `Settings` → `Actions` → `General`
2. Under "Workflow permissions":
   - ✅ Enable "Read and write permissions"
   - ✅ Enable "Allow GitHub Actions to create and approve pull requests"

### For Standalone Agent

No special permissions needed—runs in your local VS Code with your GitHub credentials.

## Which Approach Should I Use?

### Use Agentic Workflow (.github/workflows/frontmatter-checker.md) if:
- ✅ You want fully automated quality checks
- ✅ You want proactive scanning before CQP reports
- ✅ You're comfortable with agent-created PRs
- ✅ You want cache memory across runs
- ✅ You want to follow GitHub's agentics pattern

### Use Standalone Agent (.github/agents/...) if:
- ✅ You want writer-initiated fixes only (reactive)
- ✅ You're responding to specific CQP reports
- ✅ You need CSV input from CQP reports
- ✅ You want manual control over when fixes are applied

### Use Both if:
- ✅ Automated workflow catches most issues proactively
- ✅ Writers use standalone agent for urgent CQP report fixes
- ✅ You want defense in depth for quality assurance

## Testing the Agentic Workflow

### Test in GitHub Actions

Test the workflow using the repository Actions UI:

1. Go to `Actions`.
2. Select the `frontmatter-checker` workflow.
3. Click `Run workflow`.
4. Review logs and artifacts for `/tmp/frontmatter-results.md` output.

### Test the Agent Instructions

Once the workflow creates a PR:
1. Check the PR description for completeness
2. Review changed files for correctness
3. Verify cache memory was updated
4. Confirm the agent followed the rules table

## Future Enhancements

- [ ] Slack/email notifications when PRs created
- [ ] Integration with CQP API to auto-download reports
- [ ] Pre-commit hook for local validation
- [ ] Dashboard showing frontmatter quality trends over time
- [ ] Extend to other YAML frontmatter fields (permalink, sidebar, etc.)
