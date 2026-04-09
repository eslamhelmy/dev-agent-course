# Git Reviewer Skill

Schedule: 12:00 PM daily (weekdays)

## Input

Read before processing:
- `.claude/preferences.md` -- repos to monitor
- `.claude/priority-map.md` -- priority rules

## Process

1. **Query Recent Commits**
   For each repo configured in preferences.md:
   - Use: `gh api repos/{owner}/{repo}/commits --jq '.[0:20]'`
   - Or: `git log --since="24 hours ago" --oneline` for local repos
   - Collect: hash, author, message, date, files changed

2. **Analyze Each Commit**
   For each commit, determine:
   - **WHAT**: one-line summary of what changed
   - **WHY**: reason from commit message or linked issue
   - **IMPACT**: categorize changed files (API, database, UI, infra, tests, docs). Flag HIGH impact for migrations, auth changes, API breaking changes, dependency updates.

3. **Categorize**
   Group commits into: Features, Fixes, Refactors, Chores, Unknown

4. **Generate Digest**
   Format with sections: High Impact, Features, Fixes, Summary (total commits, contributors, high impact count)

## Output

Append digest to progress.txt

## State Update

- Append summary to progress.txt
- If any commit touches database migrations with no tests, add a task to tasks-active.md
