# Lesson 07 -- Git Reviewer + Standup Generator

You build two more skills. The git reviewer follows the same signal-query-prioritize-report pattern with a different data source. The standup generator demonstrates skill composition -- a skill that combines outputs from other skills into something new.

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
    cron-jobs.json                   # 2 jobs
    settings.local.json
    hooks/
      stop-telegram.sh
      permission-gate.sh
    skills/
      daily-planner/
        SKILL.md
      pr-reviewer/
        SKILL.md
```

---

## See It: Two Skills, One New Pattern

| Component | Git Reviewer | Standup Generator |
|---|---|---|
| **Type** | Signal-query-prioritize-report | **Composition** -- combines data from other skills |
| **Trigger** | Noon cron | 8:30 AM cron (after git reviewer would have run the day before) |
| **Input** | Git repos | Git commits + tasks-completed.md + tasks-active.md + progress.txt |
| **Output** | Commit digest with WHAT/WHY/IMPACT | Ready-to-paste standup message |

The git reviewer is another instance of the pattern you already know. The standup generator is new -- it reads what the agent already knows and composes a standup from it.

---

## Build It: Git Reviewer Skill

The git reviewer monitors commits across your configured repos. For each commit, it explains three things: WHAT changed, WHY it changed, and the IMPACT on the system.

**Intent:** Create a skill that reviews recent commits and produces a categorized digest.

**Prompt for Claude Code:**

```
Create the directory .claude/skills/git-reviewer/ and then create
.claude/skills/git-reviewer/SKILL.md with this content:

# Git Reviewer Skill

Schedule: 12:00 PM daily (weekdays)

## Input

Read before processing:
- .claude/preferences.md -- repos to monitor
- .claude/priority-map.md -- priority rules

## Process

1. **Query Recent Commits**
   For each repo configured in preferences.md:
   - Use: gh api repos/{owner}/{repo}/commits --jq '.[0:20]'
   - Or use: git log --since="24 hours ago" --oneline for local repos
   - Collect: hash, author, message, date, files changed

2. **Analyze Each Commit**
   For each commit, determine:
   - WHAT: One-line summary of what changed
   - WHY: Reason from commit message body or linked issue
   - IMPACT: Categorize changed files (API, database, UI,
     infrastructure, tests, docs). Flag HIGH impact: migrations,
     auth changes, API breaking changes, dependency updates.

3. **Categorize**
   Group commits into: Features, Fixes, Refactors, Chores, Unknown

4. **Generate Digest**
   Format:

   ## Git Review -- [date]
   ### High Impact
   - {hash} by {author}: {WHAT} | WHY: {reason} | IMPACT: {areas}
   ### Features
   - {hash}: {summary}
   ### Fixes
   - {hash}: {summary}
   ### Summary
   - Total commits: {count} | Contributors: {list} | High impact: {count}

## Output

Write digest to progress.txt (appended)

## State Update

- Append summary to progress.txt
- If any commit touches database migrations with no tests, add a
  task to tasks-active.md

Rules:
- Do not overwrite existing files
- Only create what is missing
- List created files when done
```

**Expected output:** Git reviewer skill file created at `.claude/skills/git-reviewer/SKILL.md`.

**Bash equivalent (optional):**
```bash
mkdir -p .claude/skills/git-reviewer
# Then manually create SKILL.md with the content above
```

---

## Build It: Standup Generator Skill

The standup generator doesn't query any external API. It reads data the agent already has -- git commits from yesterday's reviewer, completed tasks, active tasks, and progress log -- and composes a ready-to-paste standup.

**Intent:** Create a skill that generates your daily standup by combining existing agent data.

**Prompt for Claude Code:**

```
Create the directory .claude/skills/standup-generator/ and then create
.claude/skills/standup-generator/SKILL.md with this content:

# Standup Generator Skill

Schedule: 8:30 AM daily (weekdays)

## Purpose

Generate a ready-to-paste daily standup message by combining data
the agent already has. No external API calls needed.

## Input

Read these files (all internal to the agent):
- .claude/tasks-completed.md -- what was done yesterday
- .claude/tasks-active.md -- what is planned today
- .claude/progress.txt -- recent action log entries (last 24h)
- Latest git review entry in progress.txt (from git-reviewer skill)

## Process

1. **Extract Yesterday's Work**
   From tasks-completed.md, find entries dated yesterday.
   From progress.txt, find entries from yesterday.
   Combine into a deduplicated list of accomplishments.

2. **Extract Today's Plan**
   From tasks-active.md, find tasks due today or marked as
   current priority. Group by priority level.

3. **Identify Blockers**
   Scan tasks-active.md for items tagged with [blocked] or
   past deadline. Scan progress.txt for entries containing
   "blocked", "waiting", "failed", or "stuck".

4. **Include Code Activity**
   If a git review ran yesterday, summarize:
   - Number of commits authored by the user
   - Key PRs merged or reviewed

5. **Generate Standup**
   Format (ready to paste into Slack/Teams):

   **Yesterday:**
   - {accomplishment 1}
   - {accomplishment 2}
   - {accomplishment 3}

   **Today:**
   - {planned task 1}
   - {planned task 2}

   **Blockers:**
   - {blocker or "None"}

   Keep it concise -- 3-5 bullets per section max.
   Use plain language, not internal file references.
   Write "Merged PR #{number}: {title}" not "completed task from
   tasks-completed.md"

## Output

Display the standup message in the terminal for copy-paste.
Optionally send via Telegram if configured.

## State Update

- Append to progress.txt: "[timestamp] -- Standup generated:
  {yesterday_count} done, {today_count} planned, {blocker_count}
  blockers"

## Why This Skill Matters

This demonstrates SKILL COMPOSITION:
- Git reviewer runs at noon → writes to progress.txt
- Daily planner runs at 5:33 PM → updates tasks
- Standup generator runs at 8:30 AM → reads both outputs
- No skill calls another skill directly. They communicate
  through shared state files. This is the agent pattern.

Rules:
- Do not overwrite existing files
- Only create what is missing
- List created files when done
```

**Expected output:** Standup generator skill file created at `.claude/skills/standup-generator/SKILL.md`.

---

## Build It: Add Cron Entries

**Intent:** Schedule both new skills.

**Prompt for Claude Code:**

```
Add two new entries to .claude/cron-jobs.json:

{
  "id": "git-reviewer",
  "skill": ".claude/skills/git-reviewer/SKILL.md",
  "schedule": "0 12 * * 1-5",
  "description": "Review commits across repos, categorize by impact",
  "enabled": true,
  "expires": "7d",
  "last_run": null
},
{
  "id": "standup-generator",
  "skill": ".claude/skills/standup-generator/SKILL.md",
  "schedule": "30 8 * * 1-5",
  "description": "Generate daily standup from agent data",
  "enabled": true,
  "expires": "7d",
  "last_run": null
}

Keep all existing entries. The file should now have 4 jobs total.
```

**Expected output:** cron-jobs.json with four entries.

---

## Checkpoint

Your `.claude/` directory should now contain: `skills/git-reviewer/SKILL.md`, `skills/standup-generator/SKILL.md`, and `cron-jobs.json` with 4 jobs (daily-planner, pr-reviewer, git-reviewer, standup-generator).

---

Next lesson: you build the meeting ingest skill and add proper failure handling to the entire system.
