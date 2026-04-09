# Lesson 06 -- PR Review Agent

This lesson introduces a pattern you will reuse: **signal, query, prioritize, report.** You build a PR review agent that watches your GitHub repos, summarizes open pull requests, and flags risks before they become problems.

---

## Where You Are

```
your-project/
  CLAUDE.md
  .claude/
    preferences.md
    tasks-active.md
    tasks-completed.md
    progress.txt
    error-log.md
    learnings.md
    auto-resolver.md
    priority-map.md
    cron-jobs.json                   # 1 job: daily-planner
    settings.local.json
    hooks/
      stop-telegram.sh
      permission-gate.sh
    skills/
      daily-planner/
        SKILL.md
```

---

## See It: The Signal-Query-Prioritize-Report Pattern

Most monitoring skills follow the same four steps:

1. **Signal** -- Something triggers the skill. A cron fires. A webhook arrives. You invoke it manually.
2. **Query** -- The skill gathers data. It calls an API, reads a file, or checks a service.
3. **Prioritize** -- The skill ranks what it found. Not everything deserves attention.
4. **Report** -- The skill produces output. A summary, a notification, a state update.

The PR reviewer is a clean example. The cron fires (signal). It queries GitHub for open PRs (query). It flags large diffs, missing tests, security files, and stale PRs (prioritize). It writes a digest and optionally notifies you (report).

---

## See It: What the PR Reviewer Checks

The skill evaluates each open PR on five dimensions:

| Check | What It Looks For | Why It Matters |
|---|---|---|
| **Size** | Lines changed > 500 | Large PRs are hard to review and hide bugs |
| **Security** | Changes to auth, env, secrets, config | Security-sensitive changes need extra eyes |
| **Tests** | No test files modified | Code without tests is a liability |
| **Staleness** | Open for more than 3 days | Stale PRs block the team and accumulate merge conflicts |
| **Conflicts** | Merge conflict status | Cannot merge until resolved |

Each flag gets a severity: high (blocks merge), medium (needs attention), low (informational).

---

## Build It: PR Reviewer Skill

**Prerequisites:**
- The GitHub CLI (`gh`) must be installed and authenticated. Install it from https://cli.github.com/ and run `gh auth login` to authenticate before using this skill.
- Create the `.claude/reports/` directory for skill output files: `mkdir -p .claude/reports`

**Intent:** Create a skill that monitors GitHub repos for open PRs and produces a risk-flagged digest.

**Prompt for Claude Code:**

```
Create the directory .claude/skills/pr-reviewer/ and then create
.claude/skills/pr-reviewer/SKILL.md with this content:

# PR Review Agent Skill

Schedule: Configurable (default: every 4 hours during work hours)

## Input

Read before processing:
- .claude/preferences.md -- repos to monitor (look for GitHub repos list)
- .claude/priority-map.md -- priority rules for flagging

Configuration (add to preferences.md if not present):
- github_repos: list of owner/repo to monitor
- pr_review_threshold_lines: 500 (large PR threshold)
- pr_review_stale_days: 3 (stale PR threshold)

## Process

1. **Query Open PRs**
   For each configured repo:
   - Use GitHub CLI (gh) to list open pull requests
   - Command: gh pr list --repo {owner/repo} --state open --json number,title,author,createdAt,additions,deletions,changedFiles,headRefName,baseRefName,mergeable,reviewDecision,labels
   - If gh is not available, note it and skip

2. **Analyze Each PR**
   For each open PR, evaluate:

   a. Size Check:
      - additions + deletions > 500 --> flag HIGH: "Large PR ({lines} lines)"
      - additions + deletions > 200 --> flag LOW: "Medium-sized PR"

   b. Security Check:
      - Get changed files: gh pr view {number} --repo {owner/repo} --json files
      - Flag HIGH if any file matches: .env, auth, secret, credential,
        security, permission, token, password, config/prod, middleware/auth
      - Flag: "Security-sensitive files modified: {file list}"

   c. Test Check:
      - Look for test/spec files in changed files
      - If code files changed but no test files --> flag MEDIUM:
        "No tests modified"

   d. Staleness Check:
      - Calculate days since creation
      - Open > stale_days threshold --> flag MEDIUM:
        "Stale PR (open {N} days)"
      - Open > stale_days * 2 --> flag HIGH:
        "Very stale PR (open {N} days)"

   e. Conflict Check:
      - If mergeable == "CONFLICTING" --> flag HIGH: "Merge conflicts"

   f. Review Status:
      - APPROVED --> note as ready to merge
      - CHANGES_REQUESTED --> note as needs work
      - No reviews --> flag LOW: "No reviews yet"

3. **Prioritize**
   Sort PRs by:
   - Number of HIGH flags (descending)
   - Number of MEDIUM flags (descending)
   - Days open (descending)

4. **Generate Report**
   Format as a digest:

   ## PR Review Digest -- [date]

   ### Needs Attention (HIGH flags)
   For each PR with HIGH flags:
   - PR #{number}: {title} by {author}
   - Flags: [list of HIGH and MEDIUM flags]
   - Link: {url}

   ### Monitor (MEDIUM flags only)
   For each PR with only MEDIUM flags:
   - PR #{number}: {title} by {author}
   - Flags: [list]

   ### On Track (no flags or LOW only)
   - PR #{number}: {title} -- {status}

   ### Summary
   - Total open PRs: {count}
   - Needs attention: {count}
   - Ready to merge: {count}
   - Average age: {days} days

## Output

Write the digest to .claude/reports/pr-review-[date].md

## State Update

- Append to progress.txt: "[timestamp] -- PR review: {total} open PRs,
  {high_count} need attention, {ready_count} ready to merge"
- If any PR has been flagged HIGH for 3+ consecutive runs, add a P1 task
  to tasks-active.md: "Review PR #{number} in {repo} -- consistently flagged"
```

**Expected output:** A complete PR reviewer skill file.

---

## Build It: Add Repos to Preferences

**Intent:** Add GitHub repos to monitor in your preferences file.

**Prompt for Claude Code:**

```
Append the following section to .claude/preferences.md:

## GitHub Monitoring

Repos to monitor for PR reviews:
- owner/repo-name (replace with your actual repos)

Settings:
- pr_review_threshold_lines: 500
- pr_review_stale_days: 3
```

**Expected output:** Updated preferences with repo configuration.

---

## Build It: Add Cron Entry

**Intent:** Schedule the PR reviewer.

**Prompt for Claude Code:**

```
Add a new entry to .claude/cron-jobs.json for the PR reviewer:

{
  "id": "pr-reviewer",
  "skill": ".claude/skills/pr-reviewer/SKILL.md",
  "schedule": "0 9,13,17 * * 1-5",
  "description": "Review open PRs across configured repos",
  "enabled": true,
  "expires": "7d",
  "last_run": null
}

Keep the existing daily-planner entry. The file should be a JSON array
with both entries.
```

**Expected output:** cron-jobs.json with two entries.

---

## Build It: Test the PR Reviewer

**Intent:** Run the skill manually to verify it works.

**Prompt for Claude Code:**

```
Run the pr-reviewer skill. Read .claude/skills/pr-reviewer/SKILL.md
and follow its instructions. Use one of my actual repos if configured
in preferences.md, or use a well-known public repo like cli/cli as a test.
```

**Expected output:** A PR review digest file and a progress.txt entry.

---

## Checkpoint

Your `.claude/` directory should now contain: `skills/pr-reviewer/SKILL.md`, updated `preferences.md` with GitHub repos, and `cron-jobs.json` with 2 jobs (daily-planner, pr-reviewer).

---

## Fork It

- **Different repos?** Edit the repos list in preferences.md. Add as many as you need.
- **Different thresholds?** Change line count thresholds and stale-day thresholds in preferences.md.
- **Auto-comment on PRs?** Add a step in the Process section that posts a comment on HIGH-flagged PRs using `gh pr comment`. Note: this requires approval per auto-resolver.md since it sends messages.
- **Label-based filtering?** Add a step to skip PRs with a "wip" or "draft" label.
- **Team-specific rules?** Add checks for your team's conventions: required reviewers, branch naming, linked issues.
- **Slack digest?** Add a final step that posts the summary to a Slack webhook instead of (or in addition to) writing a file.

Next lesson: you build two more monitoring skills using the same pattern -- git reviewer and standup generator.
