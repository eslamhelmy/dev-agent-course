# Heartbeat Skill

Schedule: Every 2 hours

## Input

Read ALL of these files:
- `.claude/cron-jobs.json` -- check cron health
- `.claude/progress.txt` -- check freshness
- `.claude/tasks-active.md` -- check for overdue/stale tasks
- `.claude/failed-jobs.log` -- check for unresolved failures (if exists)
- `.claude/learnings.md` -- check for recent updates
- `.claude/error-log.md` -- check for recurring errors
- `.claude/priority-map.md` -- verify parseable
- `.claude/preferences.md` -- verify parseable

Also verify these skill files exist:
- `.claude/skills/daily-planner/SKILL.md`
- `.claude/skills/pr-reviewer/SKILL.md`
- `.claude/skills/git-reviewer/SKILL.md`
- `.claude/skills/standup-generator/SKILL.md`
- `.claude/skills/meeting-ingest/SKILL.md`
- `.claude/skills/learning-loop/SKILL.md`
- `.claude/skills/heartbeat/SKILL.md`

## Process

1. **Cron Health Check**
   For each entry in cron-jobs.json: verify it is active and within expiry window. Flag EXPIRED if overdue, NEVER_RUN if never executed.

2. **Progress Freshness Check**
   Parse last entry in progress.txt. If > 24h: flag MEDIUM. If > 48h: flag HIGH.

3. **Task Health Check**
   Scan tasks-active.md for overdue deadlines and stale tasks (active > 7 days with no progress).

4. **Failed Jobs Check**
   Count entries in failed-jobs.log. If > 0: flag MEDIUM. If > 5: flag HIGH. Check for repeated failures (same job 3+ times).

5. **State Validity Check**
   Parse cron-jobs.json as JSON. Verify all markdown state files are non-empty and well-structured.

6. **Skill Files Check**
   For each skill in cron-jobs.json, verify the SKILL.md file exists. Flag HIGH if missing.

7. **Learnings Check**
   If learnings.md not updated in 7+ days, note for review.

## Output

Generate a health report:

```
## Agent Health Report -- [date] [time]
### Status: {HEALTHY | DEGRADED | CRITICAL}
### Checks
| Check | Status | Details |
### Actions Taken
### Recommended Actions
```

Write report to `.claude/reports/heartbeat-[date]-[time].md`

## State Update

- Append to progress.txt: `[timestamp] -- Heartbeat: {STATUS}, {flag_count} flags ({high}H/{medium}M/{low}L)`
- For any expired crons: renew in cron-jobs.json
- If CRITICAL: send notification with HIGH flags
- If DEGRADED for 3 consecutive heartbeats: send notification

## Self-Healing Actions

The heartbeat can autonomously:
- Renew expired cron jobs
- Re-read critical files after compaction
- Retry failed jobs from failed-jobs.log (max 1 retry per heartbeat)

The heartbeat CANNOT autonomously:
- Delete tasks or files
- Modify skill logic
- Change priority levels
- Push code
