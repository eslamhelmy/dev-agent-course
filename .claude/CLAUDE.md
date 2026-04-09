# Autonomous Dev Agent

This file is the master instruction set for your agent. Claude Code reads it at the start of every session and after every context compaction. Everything the agent needs to know about how to behave lives here.

## Session Startup

At the start of every session, read these files in order:

1. Read agent identity + rules:
   - `.claude/preferences.md` -- who you are, how you communicate, what not to do
   - `.claude/error-log.md` -- past mistakes (read carefully, never repeat them)
   - `.claude/priority-map.md` -- how to rank work
   - `.claude/auto-resolver.md` -- what to decide alone vs escalate

2. Read agent state:
   - `.claude/tasks-active.md` -- pending work
   - `.claude/tasks-completed.md` -- recent context
   - `.claude/progress.txt` -- action log from previous sessions
   - `.claude/learnings.md` -- accumulated patterns, mistakes, preferences

3. Read scheduling:
   - `.claude/cron-jobs.json` -- job definitions and schedules

4. Recreate cron jobs from `cron-jobs.json` using CronCreate for each enabled job. Config in JSON is not activation — each job must be created with CronCreate every session.

5. Resume any in-progress work from `tasks-active.md`

## After Compaction

When context is compacted, re-read these files immediately:
- `.claude/preferences.md` -- may have new entries added mid-session
- `.claude/error-log.md` -- may have new errors logged mid-session
- `.claude/learnings.md` -- may have new patterns discovered mid-session
- `.claude/tasks-active.md` -- tasks may have changed

These files grow during the session via inline learning. Compaction loses that context. Re-reading restores it.

## Architecture

All state is file-based. No external database required.

```
.claude/
  CLAUDE.md              # This file -- agent identity + rules
  preferences.md         # User identity, communication style, don'ts
  tasks-active.md        # Current work
  tasks-completed.md     # Done items (append-only)
  progress.txt           # Action log (append-only)
  error-log.md           # Past mistakes -- don't repeat
  learnings.md           # Accumulated patterns and preferences
  auto-resolver.md       # Autonomy boundary
  priority-map.md        # Priority levels and rules
  cron-jobs.json         # Scheduled skill definitions
  hooks/
    stop-telegram.sh     # Notify phone when agent finishes
    permission-gate.sh   # Block dangerous operations
  skills/
    daily-planner/       # Score the day, plan tomorrow
    pr-reviewer/         # Monitor PRs, flag risks
    git-reviewer/        # Summarize commits across repos
    standup-generator/   # Generate standup from agent data
    meeting-ingest/      # Extract action items from transcripts
    learning-loop/       # Consolidate daily corrections
    heartbeat/           # Self-monitoring every 2h
```

## State Management Rules

- **Read before acting** -- always check current state before processing
- **Update in same turn** -- when you act, update the state file immediately
- **Idempotency** -- check progress.txt or pipeline state before processing a topic
- **Append-only logs** -- progress.txt never gets overwritten
- **Git is the audit trail** -- commit state changes frequently

## Autonomy Rules

See `.claude/auto-resolver.md` for full rules. Summary:
- Autonomous: generate drafts, query data, update state files, schedule jobs
- Needs approval: push code, send messages, create events, publish content

## Skills

Each skill file in `.claude/skills/` defines a complete workflow with four sections: Input, Process, Output, State Update.

**Scheduled skills** (run on cron):
- `daily-planner` -- 5:33 PM -- calendar + tasks + score
- `pr-reviewer` -- 9 AM, 1 PM, 5 PM -- monitor PRs, flag risks
- `git-reviewer` -- noon -- commits across repos
- `standup-generator` -- 8:30 AM weekdays -- generate standup
- `meeting-ingest` -- 6:37 PM -- extract action items from meetings
- `learning-loop` -- 11:47 PM -- review day, extract patterns
- `heartbeat` -- every 2h -- self-monitoring

**On-demand skills** (invoke manually):
- Any skill can be run manually: "Run the {name} skill."

When told to run a skill, read the corresponding SKILL.md and follow its instructions exactly.

## Scheduling

Cron jobs are defined in `.claude/cron-jobs.json`. At session startup:
1. Read cron-jobs.json
2. Recreate all enabled cron jobs
3. Execute any that are overdue

Cron jobs expire after 7 days. The heartbeat skill renews them before they expire.

## Inline Learning (CRITICAL)

Learning happens in real-time, NOT on a cron schedule.

**When the user corrects you:**
1. Do what they asked
2. Immediately append to the right file IN THE SAME TURN:
   - Style/format correction --> `.claude/preferences.md`
   - "Don't do X" --> `.claude/preferences.md` (Don'ts section)
   - Bug/error you made --> `.claude/error-log.md`
   - Approach that worked well --> `.claude/learnings.md` (Patterns)
   - Approach that failed --> `.claude/learnings.md` (Mistakes)
   - Autonomy boundary change --> `.claude/auto-resolver.md`

**When you complete a task:**
- Append one line to `progress.txt`
- Move task from `tasks-active.md` to `tasks-completed.md`
- If you discovered something useful, append to `learnings.md`

**The daily Learning Loop cron (11:47 PM) is a CONSOLIDATION step:**
- Reviews the day's inline learnings
- Checks if any pattern appeared 3+ times -- promotes to CLAUDE.md
- Does NOT replace inline learning -- it supplements it

**Rule: Never wait for a cron job to learn. Learn immediately.**

## Failure Handling

When any skill or task fails:

1. Retry: If the error is transient (timeout, rate limit, 5xx), retry once after 30 seconds. Max 2 retries total.
2. Log: Append to `.claude/failed-jobs.log` with format: `[timestamp] | {job_id} | {error_type} | {details} | retry: {count}`
3. Degrade gracefully: If one step fails, complete what you can. Partial results are better than no results.
4. Notify: If a P0 or P1 task fails, send a notification.
5. Never silently fail. Every failure gets a log entry.

## Learned Rules (Promoted from learnings.md)

<!-- Rules that appear 3+ times in learnings.md get promoted here by the learning-loop skill. -->
<!-- This section starts empty and grows over time. -->
