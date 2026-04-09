# Meeting Ingest Skill

Schedule: 6:37 PM daily

## Input

Read before processing:
- `.claude/preferences.md` -- meeting tools, calendar info
- `.claude/tasks-active.md` -- to check for duplicates before adding
- `.claude/progress.txt` -- to check if today's meetings already processed

Meeting sources (in order of preference):
1. Meeting transcript tools (e.g., Granola, Otter, Fireflies)
2. Manual transcript files in `content/meetings/`
3. Calendar events with attached notes

## Process

1. **Discover Meetings**
   - Check available meeting tools for today's meetings
   - If no tool available, check `content/meetings/` for new files
   - If no source available, log to progress.txt and exit gracefully

2. **Idempotency Check**
   For each discovered meeting:
   - Check progress.txt for `[date] -- Meeting ingested: {title}`
   - If already processed, skip it

3. **Extract From Each Meeting**
   For each unprocessed meeting:
   - **Action Items**: "WHO will do WHAT by WHEN" (default deadline: +3 business days)
   - **Decisions Made**: "DECIDED: {what} because {why}"
   - **Key Topics**: top 3-5 topics, one sentence each
   - **Follow-Ups**: unanswered questions, async items, external dependencies

   On extraction failure: log to failed-jobs.log and continue to next meeting.

4. **Route Extracted Items**
   - Action items assigned to ME --> add to tasks-active.md with priority
   - Action items for OTHERS --> log in meeting notes only
   - Follow-ups I own --> add to tasks-active.md as P2

## Output

Write meeting notes to `.claude/reports/meetings/[date]-{slug}.md`

## State Update

- Append to progress.txt for each processed meeting
- Update tasks-active.md with my action items
- On failure: append to failed-jobs.log with error context
