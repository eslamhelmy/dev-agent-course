# Learning Loop Skill

Schedule: 11:47 PM daily

## Input

Read these files:
- `.claude/learnings.md` -- today's inline learnings
- `.claude/error-log.md` -- today's errors
- `.claude/preferences.md` -- today's preference updates
- `.claude/progress.txt` -- full day's activity
- `.claude/CLAUDE.md` -- current learned rules section

## Process

1. **Collect Today's Learnings**
   Scan learnings.md, error-log.md, and preferences.md for entries added today. Build a list of all corrections, discoveries, and preference changes.

2. **Identify Repeated Patterns**
   Check if any pattern has appeared 3 or more times across all learning files. Patterns to look for:
   - Same mistake repeated (error-log.md)
   - Same preference correction repeated (preferences.md)
   - Same approach working repeatedly (learnings.md)

3. **Promote to CLAUDE.md**
   For any pattern that appeared 3+ times:
   - Write a concise rule in the "Learned Rules" section of CLAUDE.md
   - Format: `- **{rule}** (learned: {date}, promoted after {reason})`
   - This makes the rule permanent -- it survives context compaction

4. **Generate Daily Summary**
   Format:
   - Corrections received: {count}
   - Patterns discovered: {count}
   - Rules promoted: {count}
   - Top learning: {one-sentence summary of most significant learning}

## Output

Append the daily learning summary to progress.txt.

## State Update

- Append to progress.txt: `[timestamp] -- Learning loop: {corrections} corrections, {patterns} patterns, {promoted} promoted`
- If rules were promoted, update `.claude/CLAUDE.md` Learned Rules section
- This skill does NOT replace inline learning -- it consolidates and promotes
