# Implementation Summary: Agentic Pattern

This implementation follows the **GitHub agentics pattern** as demonstrated in the [link-checker example](https://github.com/githubnext/agentics/blob/main/workflows/link-checker.md).

## Architecture: Single File, Two Parts

### Before (Split Architecture)
```
.github/
├── scripts/
│   └── scan-frontmatter.py          ← Deterministic detection
├── workflows/
│   └── frontmatter-check.yml        ← GitHub Actions config
└── agents/
    └── jekyll-frontmatter-check-specialist.md  ← Agent instructions (standalone)
```

### After (Agentic Pattern)
```
.github/
├── workflows/
│   └── frontmatter-checker.md       ← EVERYTHING in one file
│       ├── YAML front matter (detection + workflow config)
│       └── Markdown body (agent instructions)
└── agents/
    └── jekyll-frontmatter-check-specialist.md  ← Standalone specialist
```

## Key Differences from Previous Implementation

### 1. **Single Source of Truth**
- **Before**: 3 separate files to maintain
- **After**: 1 file containing workflow + agent

### 2. **Inline Detection Script**
- **Before**: Separate Python script (`.github/scripts/scan-frontmatter.py`)
- **After**: Bash script embedded in YAML `steps` section

### 3. **Integrated Agent**
- **Before**: Separate agent file that reads JSON
- **After**: Agent instructions in same file, reads results from workflow step

### 4. **Cache Memory**
- **Before**: Not implemented
- **After**: Agent uses cache to track manual intervention cases across runs

### 5. **Safe Outputs**
- **Before**: Generic PR creation
- **After**: Structured safe outputs (`create-pull-request`, `noop`) with labels and options

## File Structure Breakdown

```markdown
---
description: What the workflow does
on: 
  schedule: When to run (cron)
  workflow_dispatch: Manual trigger options
permissions: What GitHub Actions can access
timeout-minutes: Max execution time
network:
  allowed: Tools agent can use (python, github, etc.)
steps:
  - name: Checkout
    uses: actions/checkout@v4
  - name: Scan frontmatter
    run: |
      # Bash script that:
      # 1. Finds all .adoc files
      # 2. Extracts frontmatter
      # 3. Checks for issues
      # 4. Writes report to /tmp/frontmatter-results.md
tools:
  github: GitHub API access
  cache-memory: Persistent memory across runs
safe-outputs:
  create-pull-request: PR creation config
  noop: What to do if no work needed
---

# Agent Instructions Start Here

## Your Mission
[Clear description of agent's role]

## Step 1: Review Scan Results
[How to read /tmp/frontmatter-results.md]

## Step 2: Load Cache Memory
[How to use cache for learning]

## Step 3-6: [Fix, update, create PR]
[Detailed step-by-step instructions]
```

## Benefits of This Pattern

### ✅ For Developers
- **Single file to maintain**: No sync issues between workflow and agent
- **Version control**: Changes to detection + fixing logic are atomic
- **Easier review**: See full context in one PR

### ✅ For Operations
- **Self-documenting**: Workflow config + instructions in one place
- **Less fragmentation**: Fewer files to track
- **Clear separation**: YAML = deterministic, Markdown = intelligent

### ✅ For Users
- **Simpler setup**: Just enable one workflow file
- **Automated end-to-end**: Scan → fix → PR without manual steps
- **Learning system**: Cache memory improves over time

## Backward Compatibility

The standalone agent is **still available** for reactive workflows:

- ✅ `.github/agents/jekyll-frontmatter-check-specialist.md` - CSV input for CQP reports

Writers can still use `@jekyll-frontmatter-check-agent` with CQP CSV reports for reactive, on-demand fixes.

## Migration Path

### Phase 1: Test Agentic Workflow
1. Push `frontmatter-checker.md` to repo
2. Configure workflow permissions
3. Run manually to validate
4. Review first PR created by agent

### Phase 2: Monitor Both Approaches
1. Keep agentic workflow running weekly
2. Writers continue using standalone agent for urgent CQP report fixes
3. Compare effectiveness over 2-3 weeks

### Phase 3: Adopt Primary Workflow
1. If agentic workflow catches most issues → make it primary
2. Keep standalone agent as backup for urgent fixes
3. Update documentation to reflect preferred approach

## Comparison to link-checker.md

### Similarities
| Feature | link-checker | frontmatter-checker |
|---------|--------------|-------------------|
| Single file | ✅ | ✅ |
| YAML front matter | ✅ | ✅ |
| Inline detection script | ✅ Bash | ✅ Bash |
| Agent instructions | ✅ | ✅ |
| Cache memory | ✅ | ✅ |
| Safe outputs | ✅ | ✅ |
| Step-by-step guide | ✅ | ✅ |

### Differences
| Feature | link-checker | frontmatter-checker |
|---------|--------------|-------------------|
| **Input type** | URLs | Frontmatter fields |
| **Detection** | HTTP status codes | Regex + character checks |
| **Fixing** | Find replacement URLs | Apply char rules + use [.lead] |
| **Unfixable items** | Permanently broken links | Complex markup cases |
| **Tools** | web-fetch | github (edit files) |

## Files Created

### Primary Implementation (Agentic)
- [.github/workflows/frontmatter-checker.md](workflows/frontmatter-checker.md) - **Main file** (all-in-one)

### Documentation
- [.github/README-frontmatter-tools.md](README-frontmatter-tools.md) - Complete guide
- [.github/QUICKSTART.md](QUICKSTART.md) - Quick start guide
- [.github/AGENTIC-PATTERN-SUMMARY.md](AGENTIC-PATTERN-SUMMARY.md) - This file
- [.github/IMPLEMENTATION-GUIDE.md](IMPLEMENTATION-GUIDE.md) - Detailed rollout guide

### Backward Compatibility (Standalone)
- `.github/agents/jekyll-frontmatter-check-specialist.md` - For reactive CQP workflows

### Removed (No Longer Needed)
- ~~`.github/scripts/scan-frontmatter.py`~~ - Detection now inline in bash
- ~~`.github/scripts/check-frontmatter.sh/.bat`~~ - No longer needed
- ~~`.github/scripts/test_scan_frontmatter.py`~~ - No longer needed  
- ~~`.github/workflows/frontmatter-check.yml`~~ - Replaced by frontmatter-checker.md

## Next Steps

1. ✅ **Review** the new `frontmatter-checker.md` file
2. ⏳ **Run manually in GitHub Actions** to validate behavior
3. ⏳ **Push to GitHub** and configure permissions
4. ⏳ **Trigger manually** to validate first run
5. ⏳ **Review first PR** created by agent
6. ⏳ **Enable schedule** for weekly automated runs
7. ⏳ **Document decision** to use agentic vs standalone or both

## Questions?

**Q: Should I delete the old implementation?**  
A: Not yet. Keep both for 2-3 weeks to compare. The standalone agent is still useful for CQP-driven fixes.

**Q: Can I customize the detection logic?**  
A: Yes! Edit the bash script in the `steps` section of `frontmatter-checker.md`. The agent instructions reference the character rules, so keep them in sync.

**Q: What if I need different rules per repository?**  
A: Fork the `frontmatter-checker.md` file per repo and customize the bash detection script and agent rules.

**Q: How do I disable the agentic workflow?**  
A: Delete or rename `frontmatter-checker.md`, or comment out the `schedule` trigger in the YAML front matter.
