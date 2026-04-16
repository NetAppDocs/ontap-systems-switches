# Quick Start: Frontmatter Quality Tools

Choose your workflow based on your needs.

## 🚀 Recommended: Agentic Workflow

**Best for:** Proactive automated quality checks

### Setup (One Time)

1. **Enable the workflow**
   ```bash
   git add .github/workflows/frontmatter-checker.md
   git commit -m "Enable automated frontmatter quality checks"
   git push
   ```

2. **Configure permissions**
   - Go to repo `Settings` → `Actions` → `General`
   - Enable "Read and write permissions"
   - Enable "Allow GitHub Actions to create and approve pull requests"

3. **Done!** The workflow will run every Monday at 9am UTC

### How It Works

```
Monday 9am UTC
      ↓
GitHub Actions triggers workflow
      ↓
Bash script scans all .adoc files
      ↓
Identifies frontmatter issues
      ↓
Agent reads results (/tmp/frontmatter-results.md)
      ↓
Agent applies intelligent fixes
      ↓
Agent creates PR with fixes
      ↓
You review and merge PR
```

### Manual Trigger

```
1. Go to Actions tab
2. Select "Frontmatter Quality Checker"
3. Click "Run workflow"
4. Wait ~2-5 minutes
5. PR appears automatically
```

---

## 🔧 Alternative: Standalone Agent

**Best for:** Reactive fixes from CQP reports

### Setup

No setup needed—just invoke the agent in VS Code.

### How It Works

```
CQP report arrives
      ↓
Download CSV report
      ↓
Open VS Code in repo
      ↓
@jekyll-frontmatter-check-agent
      ↓
Provide CSV path
      ↓
Agent scans, fixes, creates PR
```

### Usage

```
You: @jekyll-frontmatter-check-agent
Agent: Please provide the path to the CQP CSV file.
You: C:\Users\jsnyder\Downloads\cqp_report_12345.csv
Agent: Found 23 files from CSV. Starting inspection...
       Batch 1/3 complete: 10 processed, 8 fixed, 0 errors
       Batch 2/3 complete: 10 processed, 9 fixed, 0 errors
       Batch 3/3 complete: 3 processed, 2 fixed, 0 errors
       
       Create a pull request with these fixes? (yes/no)
You: yes
Agent: Created PR #456: Fix frontmatter quality issues in documentation
```

---

## 📊 Comparison

| Feature | Agentic Workflow | Standalone Agent |
|---------|-----------------|------------------|
| **Trigger** | Automated schedule | Manual invocation |
| **Input** | Auto-scans repo | CSV or JSON file |
| **Detection** | Bash script (inline) | Python script or CSV |
| **Fixing** | Agent (automated) | Agent (manual) |
| **PR creation** | Automatic | On user confirmation |
| **Cache memory** | Yes (across runs) | No (fresh each time) |
| **Best for** | Proactive quality | Reactive CQP fixes |
| **Setup effort** | Medium (permissions) | None (works immediately) |

---

## 💡 Pro Tip: Use Both

**Typical workflow:**
1. **Agentic workflow** runs weekly, catches most issues proactively
2. **Standalone agent** used by writers for urgent CQP report fixes
3. Both approaches complement each other for robust quality assurance

---

## 🆘 Troubleshooting

### Agentic workflow not running
- Check: Is the workflow file in `.github/workflows/`?
- Check: Are workflow permissions enabled?
- Check: Is the schedule cron expression correct?

### Agent creates empty PR
- The workflow might have found no issues
- Check workflow run logs in Actions tab
- Review `/tmp/frontmatter-results.md` output in logs

### Standalone agent asks for CSV
- Provide the full path to your CQP CSV report file
- Example: `C:\Users\jsnyder\Downloads\cqp_report_12345.csv`

### PR has incorrect fixes
- Review the character rules in the workflow
- Check if `[.lead]` paragraphs exist in affected files
- Some complex cases may need manual intervention

---

## 📚 More Info

- [README-frontmatter-tools.md](README-frontmatter-tools.md) - Detailed documentation
- [IMPLEMENTATION-GUIDE.md](IMPLEMENTATION-GUIDE.md) - Rollout strategy
- [frontmatter-checker.md](workflows/frontmatter-checker.md) - Agentic workflow source
