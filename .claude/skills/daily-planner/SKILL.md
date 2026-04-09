# Daily Planner Skill

Schedule: 5:33 PM daily

## Input

Read these files before processing:
- `.claude/tasks-active.md` -- current work
- `.claude/tasks-completed.md` -- what got done today
- `.claude/progress.txt` -- today's action log
- `.claude/preferences.md` -- user identity and calendar info

## Process

1. **Review Today**
   - Count tasks completed today (from tasks-completed.md)
   - Count tasks still active (from tasks-active.md)
   - List key actions from progress.txt (today's entries only)

2. **Score the Day**
   - Rate productivity 1-10 based on:
     - Tasks completed vs planned
     - P0/P1 items cleared
     - Any blockers resolved
   - Note what went well
   - Note what could improve

3. **Plan Tomorrow**
   - List carry-over tasks from tasks-active.md
   - Identify top 3 priorities for tomorrow
   - Flag any deadlines within 48 hours

4. **Generate Summary**
   - Format as a concise daily report
   - Include: score, completed count, carry-over count, top 3 tomorrow

## Output

Write the daily report to `.claude/reports/daily/[date].md`

## State Update

- Append to progress.txt: `[timestamp] -- Daily planner: scored [X]/10, [N] tasks completed, [M] carry-over`
- If any task has been active for more than 5 days without progress, flag it in the report and add a note to tasks-active.md
