# Implementation Guide: Agentic Workflow Pattern

This guide explains how to implement and use the frontmatter quality checking tools based on the GitHub agentics pattern.

## What You Have Now

✅ **Agentic Workflow** - `.github/workflows/frontmatter-checker.md` (primary)
✅ **Standalone Agent** - `.github/agents/jekyll-frontmatter-check-specialist.md` (backup)
✅ **Workflow Validation Path** - Manual run in GitHub Actions
✅ **Documentation** - Complete guides in `.github/`

## Testing the Implementation

### 1. Test the Agentic Workflow

Once you push the workflow file to GitHub:

**Manual trigger via GitHub UI**
```
1. Go to repository → Actions tab
2. Select the `frontmatter-checker` workflow
3. Click "Run workflow"
4. Select branch and optionally add file filter
5. Workflow runs and creates PR if issues found
```

### 2. Test the Standalone Agent

For reactive fixes from CQP reports:

```
You: @jekyll-frontmatter-check-agent
Agent: [asks for CSV path]
You: C:\Users\jsnyder\Downloads\cqp_report_12345.csv
Agent: [scans files, applies fixes, creates PR]
```

### 3. Enable the Agentic Workflow

**Push the workflow file:**
```bash
git add .github/workflows/frontmatter-checker.md
git commit -m "Add frontmatter quality checking workflow"
git push
```

**Configure permissions in GitHub:**

1. Go to `Settings` → `Actions` → `General`
2. Under "Workflow permissions":
   - ✅ Enable "Read and write permissions"
   - ✅ Enable "Allow GitHub Actions to create and approve pull requests"

The workflow will now run:
- Automatically every Monday at 9am UTC
- Manually via Actions tab → "Run workflow"

## Usage Scenarios

### Scenario 1: Automated Weekly Scan (Primary)

**When:** Proactive quality checks on main branch

```
1. Workflow runs automatically every Monday 9am UTC
2. Bash script scans all .adoc files for issues
3. Agent reads results and applies intelligent fixes
4. PR automatically created if fixes applied
5. Writers review and merge the PR
```

### Scenario 2: Manual Workflow Trigger

**When:** You want to run a scan on-demand

```
1. Go to Actions tab in GitHub
2. Select the `frontmatter-checker` workflow
3. Click "Run workflow"
4. Optionally filter to specific files
5. Review PR created by agent
```

### Scenario 3: Reactive (Writer-initiated)

**When:** Writer gets a CQP report with frontmatter issues

```
1. Download CQP CSV to local machine
2. Open VS Code in repository
3. Run: @jekyll-frontmatter-check-agent
4. Provide CSV path when prompted
5. Agent processes and creates PR
```

### Scenario 4: Pre-merge Validation

**When:** Writer wants to validate behavior before merge

```
1. Run the workflow manually from the Actions tab
2. Select the branch being validated
3. Optionally set a file filter for targeted validation
4. Review the PR created by the agent
```

## Rollout Strategy

### Phase 1: Manual Workflow Validation (1 week)
- Run the workflow manually to see issues
- Review the types of issues found
- Validate the character rules make sense
- Test standalone agent with a small CSV if desired

### Phase 2: Enable Agentic Workflow (1-2 weeks)
- Push workflow file to repository
- Configure GitHub Actions permissions
- Run workflow manually first (don't wait for Monday)
- Review the PR created by the agent
- Verify fixes are correct and merge

### Phase 3: Monitor Automated Runs (2-3 weeks)
- Let workflow run automatically on Mondays
- Review PRs created each week
- Track fix quality and any false positives
- Adjust character rules if needed

### Phase 4: Full Adoption (ongoing)
- Workflow becomes primary quality gate
- Standalone agent remains for urgent CQP fixes
- Consider rolling out to other repositories
- Monitor trends and adjust rules as needed

## Customization Options

### Adjust Scan Frequency

Edit `.github/workflows/frontmatter-checker.md` YAML front matter:
```yaml
schedule:
  - cron: '0 9 * * 1'  # Weekly Monday 9am UTC (current)
  # - cron: '0 0 * * *'  # Daily midnight
  # - cron: '0 9 1 * *'  # Monthly 1st day
```

### Modify Detection Logic

Edit the bash script in the workflow file (`.github/workflows/frontmatter-checker.md`):

```bash
# Change disallowed characters
DISALLOWED='!@#$%&*()+=[]{}|\\:;,<>?/'  # Adjust as needed

# Add more AsciiDoc markup patterns
if [[ "$SUMMARY" =~ \~\~[^~]+\~\~ ]]; then
  FILE_ISSUES="$FILE_ISSUES\n  - summary: contains strikethrough markup (~~text~~)"
fi
```

### Exclude Additional Paths

Edit the file finding logic in the workflow:
```bash
ADOC_FILES=$(find . -type f -name "*.adoc" \
  ! -path "./_include/*" \
  ! -path "./redirect/*" \
  ! -name "_*" \
  ! -path "./draft/*" \    # Add custom exclusions
  ! -path "./archived/*")  # Add more as needed
```

### Update Agent Rules

Edit `.github/workflows/frontmatter-checker.md` agent instructions section to adjust:
- When to use `[.lead]` paragraph threshold
- Character replacement rules
- Manual intervention criteria

## Monitoring & Maintenance

### Check Workflow Results
```bash
# View workflow status
gh run list --workflow=frontmatter-checker.md

# View latest run details
gh run view $(gh run list --workflow=frontmatter-checker.md --limit 1 --json databaseId -q '.[0].databaseId')

# See workflow logs
gh run view --log
```

### Review Agent Fixes
After agent creates PRs:
1. Check PR description for summary of changes
2. Spot-check 5-10 fixed files
3. Verify summaries are readable
4. Confirm markup was properly stripped
5. Look for cache memory updates in PR notes

### Update Rules
If you find edge cases or false positives:
1. Run the workflow manually in Actions
2. Update detection logic in workflow file
3. Update agent instructions in same file
4. Run the workflow manually again to validate changes
5. Document the change in commit message

## Troubleshooting

### Detection finds too many false positives
- Review the DISALLOWED character string in workflow
- Check if certain characters should be allowed in specific fields
- Update the bash regex patterns for AsciiDoc markup
- Test changes locally before pushing

### Agent makes incorrect fixes
- Review cache memory to see if issues were flagged for manual intervention
- Check the "Summary rewrite threshold" logic in agent instructions
- Verify `[.lead]` paragraphs exist and are appropriate
- Adjust agent rules in the workflow file

### Workflow fails with permissions error
- Check repository `Settings` → `Actions` → `General` → Permissions
- Verify "Read and write permissions" is enabled
- Verify "Allow GitHub Actions to create and approve pull requests" is checked
- Ensure workflow has `contents: write` and `pull-requests: write` in YAML

### Manual run does not start
- Verify the workflow file is present at `.github/workflows/frontmatter-checker.md`
- Confirm repository Actions permissions are enabled
- Check repository and organization Actions policy settings

## Next Steps

1. ✅ Review the agentic workflow file
2. ⏳ Run workflow manually in Actions
3. ⏳ Push workflow to GitHub
4. ⏳ Configure Actions permissions
5. ⏳ Run workflow manually first
6. ⏳ Review and merge first PR
7. ⏳ Monitor automated runs for 2-3 weeks
8. ⏳ Decide: keep or adjust scan frequency

## Questions?

**Q: What's the difference between the agentic workflow and standalone agent?**  
A: Agentic workflow runs automatically on a schedule and scans all files. Standalone agent is manually invoked for specific CSV-based fixes from CQP reports.

**Q: Can we use both?**  
A: Yes! Use agentic workflow for proactive automated checks, and standalone agent for urgent reactive fixes from CQP reports.

**Q: What if the workflow finds hundreds of issues?**  
A: The agent processes in batches using cache memory. You can review the PR and either merge all fixes or cherry-pick specific files. The workflow will continue finding new issues on subsequent runs.

**Q: How do we test changes to the workflow?**  
A: Push to a test branch and run the workflow manually on that branch before merging to main.

**Q: What if we want different rules per repository?**  
A: Copy the workflow file to each repository and customize the detection logic and agent instructions independently. The agentic pattern makes this easy since everything is in one file.

**Q: Can writers run this on their feature branches?**  
A: Yes. Writers can run the workflow manually and select their feature branch in the Actions UI.

**Q: How do we update the character rules?**  
A: Edit the `DISALLOWED` variable in the bash script section of `.github/workflows/frontmatter-checker.md`. Then run the workflow manually to validate and push the change.
