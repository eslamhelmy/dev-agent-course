# Skill Evaluator — Nightly Audit

## Purpose
Evaluate all agent skills at 3 AM, identify improvements based on accumulated learnings, errors, and new capabilities. Generate a recommendation report for user review in the morning.

## Schedule
`3 3 * * *` — 3:03 AM daily

## Input
Read these files:
- `.claude/learnings.md` — patterns, mistakes, preferences
- `.claude/error-log.md` — past errors
- `.claude/progress.txt` — recent skill execution results (last 7 days)
- `.claude/failed-jobs.log` — failed skill runs
- All skill files: `.claude/skills/*/SKILL.md`
- `CLAUDE.md` — learned rules section

## Process

### Step 0: Capability Pre-Check
Before running anything, verify all critical state files exist:
- Check for: `learnings.md`, `error-log.md`, `progress.txt` (critical), `failed-jobs.log` (optional)
- If all critical files exist → proceed to Step 1
- If `failed-jobs.log` missing → note it, proceed with partial evaluation (skip failure analysis)
- If any critical file is missing → **DEGRADE**: log to `progress.txt` (if available), proceed with whatever files are available

### 1. Collect Evidence
For each skill, gather:
- Last execution date and result (from progress.txt)
- Any errors or failures (from error-log.md, failed-jobs.log)
- Related learnings (from learnings.md — match by skill name or keywords)
- Related feedback (from preferences.md — match by don'ts or corrections)

### 2. Evaluate Each Skill on 5 Dimensions

**a. Effectiveness** — Does it achieve its goal?
- Check last 7 days of progress.txt for success/failure rate
- Any recurring errors?

**b. Approach** — Is there a better way now?
- Check learnings.md for discovered patterns that could improve the skill
- Check if new MCPs, tools, or capabilities exist that the skill doesn't use

**c. Relevance** — Is this skill still needed?
- Check if the task it automates has been dropped, completed, or changed
- Check if user explicitly said to stop doing something (preferences.md don'ts)

**d. Reliability** — Does it run without manual intervention?
- Check failed-jobs.log for this skill
- Check if it depends on fragile integrations (browser automation, login walls)
- Rate: autonomous / needs-help / broken

**e. Efficiency** — Is it wasting time or tokens?
- Is the skill doing unnecessary work?
- Can steps be removed or combined?
- Is it reading files it doesn't need?

### 3. Score Each Skill

```
Skill: [name]
Last Run: [date] — [result]
Scores: Effectiveness [1-5] | Approach [1-5] | Relevance [1-5] | Reliability [1-5] | Efficiency [1-5]
Overall: [average]/5
```

### 4. Generate Recommendations

For each skill scoring below 4 on any dimension:

```
## [Skill Name] — [Overall Score]/5

**Issue:** [what's wrong]
**Evidence:** [from which file/entry]
**Recommendation:** [specific change to SKILL.md]
**Priority:** [high/medium/low]
**Effort:** [minutes to implement]
```

### 5. Check for Missing Skills
Based on learnings.md and progress.txt, identify:
- Repeated manual tasks that should be automated
- Patterns that appear 3+ times without a skill
- User requests that required multiple steps that could be a single skill

## Output

Write report to: `.claude/reports/skill-eval-[date].md`

Format:
```markdown
# Skill Evaluation Report — [Date]

## Summary
- Skills evaluated: [count]
- Healthy (4+): [count]
- Needs improvement (3-3.9): [count]
- Critical (<3): [count]
- New skill suggestions: [count]

## Critical Issues (fix first)
[skills scoring <3 on any dimension]

## Improvement Recommendations
[skills scoring 3-3.9]

## Healthy Skills
[skills scoring 4+ — just list names]

## Missing Skills (suggest new)
[patterns that should become skills]

## Changes Since Last Evaluation
[what improved, what degraded]
```

## State Update
- Append summary to progress.txt
- If any skill is scored "broken" (reliability <2): notify the user

## Rules
- Never modify skill files automatically — only recommend
- User reviews and approves changes in the morning
- Compare with previous evaluation to track trends
- Don't recommend changes for skills that haven't run in the last 7 days (mark as "inactive — skip")
