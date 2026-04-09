# Lesson 08 -- Meeting Ingest + Failure Handling

You have four skills running. But what happens when one of them fails? A missing API key. A rate limit. A malformed response. A service outage. Until now, you have ignored failure. This lesson fixes that. You will build the meeting ingest skill and, more importantly, add failure handling infrastructure to the entire agent.

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
    cron-jobs.json                   # 5 jobs
    settings.local.json
    hooks/
      stop-telegram.sh
      permission-gate.sh
    skills/
      daily-planner/
        SKILL.md
      pr-reviewer/
        SKILL.md
      git-reviewer/
        SKILL.md
      standup-generator/
        SKILL.md
```

---

## See It: The Signal Source Pattern

Meeting ingest follows a slightly different pattern than the monitoring skills. Instead of signal-query-prioritize-report, it uses a five-step pattern for processing external signal sources:

```
Signal --> Extract --> Route --> Track --> Follow Up
```

1. **Signal** -- A meeting transcript arrives (from Granola, Otter, manual upload, or calendar integration).
2. **Extract** -- Pull out structured data: action items, decisions, key topics, participants.
3. **Route** -- Send each extracted item to the right place: tasks go to tasks-active.md, decisions go to a meeting notes file, follow-ups get scheduled.
4. **Track** -- Update state to record that this meeting was processed (idempotency).
5. **Follow Up** -- If any action item has a deadline, create a reminder.

This pattern applies to any external data source: meeting notes, Slack threads, document reviews, customer feedback.

## See It: Why Failure Handling Matters

Here is what happens without failure handling:

1. The standup generator skill runs at 8 AM. An API returns a 429 (rate limit).
2. The skill crashes silently. No report is generated.
3. You do not know it failed. No notification. No log entry.
4. The next day, same thing. Now you have missed 2 days of standup generation and do not know it.

With failure handling:

1. The standup generator skill runs at 8 AM. An API returns a 429.
2. The skill catches the error. It retries once after 30 seconds.
3. If it still fails, it logs the failure to `failed-jobs.log` with the error details.
4. It sends a Telegram notification: "Standup generator failed: rate limit exceeded."
5. The heartbeat skill (lesson 09) checks failed-jobs.log every 2 hours and can retry.

## See It: The Four Failure Mechanisms

| Mechanism | What It Does |
|---|---|
| **Retry** | Try again after a short delay. Max 2 retries per run. |
| **Idempotency** | Check if this input was already processed. Skip if yes. |
| **Dead-letter log** | Write failures to failed-jobs.log with full context for later analysis. |
| **Graceful degradation** | If one step fails, still complete the others. Partial results beat no results. |

---

## Build It: Failed Jobs Log

**Intent:** Create the dead-letter log where failed skill runs are recorded.

**Prompt for Claude Code:**

```
Create .claude/failed-jobs.log with this content:

# Failed Jobs Log
# Append-only. Each entry records a skill failure with context for retry.
# Format: [timestamp] | job_id | error_type | details | retry_count
```

**Expected output:** A log file with a header comment.

---

## Build It: Meeting Ingest Skill

**Intent:** Create the meeting ingest skill with built-in failure handling.

**Prompt for Claude Code:**

```
Create the directory .claude/skills/meeting-ingest/ and then create
.claude/skills/meeting-ingest/SKILL.md with this content:

# Meeting Ingest Skill

Schedule: 6:37 PM daily

## Input

Read before processing:
- .claude/preferences.md -- meeting tools, calendar info
- .claude/tasks-active.md -- to check for duplicates before adding
- .claude/progress.txt -- to check if today's meetings already processed

Meeting sources (in order of preference):
1. Granola MCP tools (if available)
2. Manual transcript files in content/meetings/
3. Calendar events with attached notes

## Process

1. **Discover Meetings**
   - Check Granola for today's meetings using MCP tools
   - If Granola unavailable, check content/meetings/ for new files
   - If no source available, log to progress.txt and exit gracefully
   - Build list of meetings to process: title, participants, duration, source

2. **Idempotency Check**
   For each discovered meeting:
   - Check progress.txt for "[date] -- Meeting ingested: {title}"
   - If already processed, skip it
   - This prevents duplicate processing on retries or repeated runs

3. **Extract From Each Meeting**
   For each unprocessed meeting:

   a. Action Items
      - Identify tasks assigned to specific people
      - Format: "WHO will do WHAT by WHEN"
      - If no deadline mentioned, set to +3 business days

   b. Decisions Made
      - Key decisions with brief context
      - Format: "DECIDED: {what} because {why}"

   c. Key Topics Discussed
      - Top 3-5 topics covered
      - One sentence each

   d. Follow-Ups Needed
      - Questions left unanswered
      - Items that need async follow-up
      - External dependencies mentioned

   FAILURE HANDLING for extraction:
   - If transcript is too long, summarize in chunks
   - If transcript is garbled/unclear, extract what you can and flag
     "[PARTIAL] -- transcript quality poor"
   - If extraction fails entirely, log to failed-jobs.log and continue
     to next meeting

4. **Route Extracted Items**

   a. Action items assigned to ME:
      - Add as tasks to tasks-active.md
      - Set priority based on deadline (within 24h = P1, within week = P2)
      - Include meeting reference

   b. Action items assigned to OTHERS:
      - Log in meeting notes file for tracking
      - Do NOT add to my tasks-active.md

   c. Decisions:
      - Write to meeting notes file

   d. Follow-ups:
      - If I own the follow-up, add to tasks-active.md as P2
      - If someone else owns it, note in meeting file

5. **Track Processing**
   For each successfully processed meeting:
   - Append to progress.txt: "[timestamp] -- Meeting ingested: {title}
     ({N} action items, {M} decisions)"
   - Write full meeting notes to .claude/reports/meetings/[date]-{slug}.md

## Output

For each meeting, write to .claude/reports/meetings/[date]-{meeting-slug}.md:

## Meeting Notes: {title}
Date: {date}
Participants: {list}
Duration: {duration}

### Action Items
- [ ] {WHO}: {WHAT} (by {WHEN})

### Decisions
- {decision with context}

### Key Topics
- {topic summary}

### Follow-Ups
- {follow-up item}

## State Update

- Update tasks-active.md with my action items
- Append to progress.txt for each processed meeting
- If any meeting failed to process, append to failed-jobs.log:
  "[timestamp] | meeting-ingest | {error_type} | Meeting: {title},
  Error: {details} | retry: 0"

## Failure Handling

On any error during processing:
1. Log the error context to failed-jobs.log
2. If the error is retryable (API timeout, rate limit):
   - Wait 30 seconds
   - Retry once
   - If still failing, log with retry count and move on
3. If the error is not retryable (missing data, parse error):
   - Log immediately, do not retry
4. Always continue to the next meeting -- one failure should not
   block the rest
5. At the end, if any meetings failed:
   - Include failure count in progress.txt entry
   - Send Telegram notification: "{N} of {M} meetings failed to ingest"
```

**Expected output:** A complete meeting ingest skill with failure handling.

---

## Build It: Add Failure Handling to CLAUDE.md

**Intent:** Add system-wide failure handling rules to the master instruction file.

**Prompt for Claude Code:**

```
Append the following section to CLAUDE.md:

## Failure Handling

When any skill or task fails:

1. Retry: If the error is transient (timeout, rate limit, 5xx),
   retry once after 30 seconds. Max 2 retries total.

2. Log: Append to .claude/failed-jobs.log with format:
   [timestamp] | {job_id} | {error_type} | {details} | retry: {count}

3. Degrade gracefully: If one step fails, complete what you can.
   Partial results are better than no results.

4. Notify: If a P0 or P1 task fails, send Telegram notification.

5. Never silently fail. Every failure gets a log entry.
```

**Expected output:** CLAUDE.md updated with failure handling rules.

---

## Build It: Add Cron Entry

**Intent:** Schedule the meeting ingest skill.

**Prompt for Claude Code:**

```
Add a new entry to .claude/cron-jobs.json:

{
  "id": "meeting-ingest",
  "skill": ".claude/skills/meeting-ingest/SKILL.md",
  "schedule": "37 18 * * 1-5",
  "description": "Extract action items from today's meetings",
  "enabled": true,
  "expires": "7d",
  "last_run": null
}

Keep all existing entries. The file should now have 5 jobs total.
```

**Expected output:** cron-jobs.json with five entries.

---

## Checkpoint

After this lesson, your project should contain:

```
your-project/
  CLAUDE.md                          # Updated with failure handling rules
  .claude/
    preferences.md
    tasks-active.md
    tasks-completed.md
    progress.txt
    error-log.md
    learnings.md
    auto-resolver.md
    priority-map.md
    cron-jobs.json                   # 5 jobs
    failed-jobs.log                  # NEW
    settings.local.json
    hooks/
      stop-telegram.sh
      permission-gate.sh
    skills/
      daily-planner/
        SKILL.md
      pr-reviewer/
        SKILL.md
      git-reviewer/
        SKILL.md
      standup-generator/
        SKILL.md
      meeting-ingest/
        SKILL.md                     # NEW
```

The cron schedule is now:
- 8:00 AM -- Standup generator
- 9 AM, 1 PM, 5 PM -- PR reviewer
- 12:00 PM -- Git reviewer
- 5:33 PM -- Daily planner
- 6:37 PM -- Meeting ingest

And every skill now has a safety net: retries, idempotency checks, dead-letter logging, and graceful degradation.

---

## Fork It

- **Otter.ai instead of Granola?** Change the meeting source in the Process section. Otter provides transcripts via email or API -- adjust the discovery step accordingly.
- **Microsoft Teams transcripts?** Teams stores transcripts in OneDrive. Add a discovery step that checks your recent Teams meetings.
- **Zoom recordings?** Zoom's API provides transcripts for recorded meetings. Add as another source in the priority list.
- **Stricter retry policy?** Change the retry count or delay. For rate-limited APIs, use exponential backoff (30s, then 60s, then 120s).
- **Failure alerting?** Create a separate hook that watches failed-jobs.log and sends an alert when it grows beyond a threshold.
- **Team meetings?** Add logic to distribute action items to team members via Slack or email (with approval per auto-resolver.md).

Next lesson: you build the heartbeat -- the skill that monitors the agent itself.
