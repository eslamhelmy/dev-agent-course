# Standup Generator Skill

Schedule: 8:30 AM daily (weekdays)

## Input

Read these files (all internal to the agent):
- `.claude/tasks-completed.md` -- what was done yesterday
- `.claude/tasks-active.md` -- what is planned today
- `.claude/progress.txt` -- recent action log entries (last 24h)

## Process

1. **Extract Yesterday's Work**
   From tasks-completed.md, find entries dated yesterday. From progress.txt, find yesterday's entries. Combine into a deduplicated list of accomplishments.

2. **Extract Today's Plan**
   From tasks-active.md, find tasks due today or marked as current priority. Group by priority level.

3. **Identify Blockers**
   Scan tasks-active.md for items tagged with [blocked] or past deadline. Scan progress.txt for entries containing "blocked", "waiting", "failed", or "stuck".

4. **Include Code Activity**
   If a git review ran yesterday, summarize: number of commits authored, key PRs merged or reviewed.

5. **Generate Standup**
   Format (ready to paste into Slack/Teams):

   **Yesterday:**
   - {accomplishment 1}
   - {accomplishment 2}

   **Today:**
   - {planned task 1}
   - {planned task 2}

   **Blockers:**
   - {blocker or "None"}

   Keep it concise -- 3-5 bullets per section max. Use plain language, not internal file references.

## Output

Display the standup message in the terminal for copy-paste. Optionally send via notification if configured.

## State Update

- Append to progress.txt: `[timestamp] -- Standup generated: {yesterday_count} done, {today_count} planned, {blocker_count} blockers`
