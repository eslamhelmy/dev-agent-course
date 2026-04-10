# Autonomous Dev Agent

> Your code runs. Your agent runs alongside it.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Built%20with-Claude%20Code-blueviolet)](https://claude.ai/claude-code)
[![Course](https://img.shields.io/badge/Course-8%20Lessons-blue)](https://eslamhelmy.tech/blog/dev-agent-course)

A persistent developer agent that works while you work. It reviews PRs, summarizes commits, generates standups, ingests meetings, learns from every correction, and self-heals when things break. No frameworks. No cloud services. Just files, cron jobs, and a feedback loop.

## What It Does

| Skill | Schedule | What Happens |
|-------|----------|-------------|
| **Daily Planner** | 5:33 PM | Reviews your tasks, checks calendar, scores the day 1-10 |
| **PR Reviewer** | 9 AM, 1 PM, 5 PM | Flags size, security, and staleness risks on open PRs |
| **Git Reviewer** | Noon | Summarizes commits with WHAT / WHY / IMPACT analysis |
| **Standup Generator** | 8:30 AM | Composes a ready-to-paste standup from agent data |
| **Meeting Ingest** | 6:37 PM | Extracts action items and decisions from transcripts |
| **Learning Loop** | 11:47 PM | Consolidates corrections, promotes repeated patterns |
| **Heartbeat** | Every 2h | Self-monitors crons, state files, deadlines, failures |

Every skill reads shared state files, acts, and updates them. Skills communicate through files, not function calls. The agent gets smarter every day because corrections are logged and fed back into future decisions.

## Get Started

```bash
git clone https://github.com/eslamhelmy/autonomous-dev-agent.git
cd autonomous-dev-agent
```

1. Read **[ARCHITECTURE.md](ARCHITECTURE.md)** to understand the system
2. Edit **`.claude/preferences.md`** with your name, role, and communication style
3. Customize the skills in **`.claude/skills/`** to match your workflow
4. Run **`claude`**

## Project Structure

```
.claude/
  CLAUDE.md              # Agent identity + rules
  preferences.md         # Your name, role, style, don'ts
  tasks-active.md        # Current work
  tasks-completed.md     # Done items
  progress.txt           # Action log (append-only)
  error-log.md           # Past mistakes — agent reads to avoid repeating
  learnings.md           # Patterns the agent discovered over time
  priority-map.md        # P0-P3 priority definitions
  cron-jobs.json         # Scheduled skill definitions
  hooks/
    stop-telegram.sh     # Notify your phone when agent finishes
    permission-gate.sh   # Block force pushes + destructive deletes
  skills/
    daily-planner/       # Score the day, plan tomorrow
    pr-reviewer/         # Monitor PRs, flag risks
    git-reviewer/        # Summarize commits across repos
    standup-generator/   # Generate standup from agent data
    meeting-ingest/      # Extract action items from meetings
    learning-loop/       # Consolidate daily corrections
    heartbeat/           # Self-monitoring every 2h
```

## How It Learns

```
You correct the agent  -->  Logged to learnings.md  -->  Agent reads it next time
Same correction 3x     -->  Promoted to CLAUDE.md    -->  Permanent rule
```

The agent improves through a simple feedback loop: you correct it, it logs the correction, and it never makes the same mistake twice. After three occurrences, the pattern becomes a permanent rule.

## Build It Yourself

Want to understand why every file exists and how to build this from scratch?

**[Read the step-by-step course (8 lessons)](https://eslamhelmy.tech/blog/dev-agent-course)** — it walks through the architecture, state management, skills, hooks, scheduling, self-healing, and remote access.

## Author

Built by **[Eslam Helmy](https://github.com/eslamhelmy)**

YouTube: [@arabdevsimplified](https://youtube.com/@arabdevsimplified) | Blog: [eslamhelmy.tech](https://eslamhelmy.tech)

If this is useful, a star helps others find it.

## License

[MIT](LICENSE) — fork it, modify it, make it yours.
