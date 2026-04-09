# Dev Agent Template

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Built%20with-Claude%20Code-blueviolet)](https://claude.ai/claude-code)

A forkable template for building a persistent, autonomous developer agent with [Claude Code](https://claude.ai/claude-code). No frameworks. No cloud services. Just files, cron jobs, and a feedback loop that makes the agent smarter every day.

## Get Started

```bash
git clone https://github.com/eslamhelmy/autonomous-dev-agent.git && cd autonomous-dev-agent
```

Read [ARCHITECTURE.md](ARCHITECTURE.md), edit `.claude/preferences.md` with your identity, customize the skills, then run `claude`.

## What's Inside

```
.claude/
  CLAUDE.md                          # Agent identity + rules
  preferences.md                     # Your name, role, communication style
  tasks-active.md                    # Current work
  tasks-completed.md                 # Done items
  progress.txt                       # Action log
  error-log.md                       # Past mistakes
  learnings.md                       # Patterns the agent discovered
  priority-map.md                    # P0-P3 priority definitions
  cron-jobs.json                     # Scheduled skills
  hooks/
    stop-telegram.sh                 # Notify your phone when agent finishes
    permission-gate.sh               # Block dangerous operations
  skills/
    daily-planner/SKILL.md           # Score the day, plan tomorrow
    pr-reviewer/SKILL.md             # Monitor PRs, flag risks
    git-reviewer/SKILL.md            # Summarize commits across repos
    standup-generator/SKILL.md       # Generate standup from agent data
    meeting-ingest/SKILL.md          # Extract action items from meetings
    learning-loop/SKILL.md           # Consolidate daily corrections
    heartbeat/SKILL.md               # Self-monitoring every 2h
```

## Learn How to Build This

Want to understand why every file exists? Read the [step-by-step course (8 lessons)](https://eslamhelmy.tech/blog/dev-agent-course) — it explains the thinking behind each decision.

## Who Made This

Built by [Eslam Helmy](https://github.com/eslamhelmy) -- Lead Engineer at Edenred UAE, YouTube [@arabdevsimplified](https://youtube.com/@arabdevsimplified).

If this is useful, a star helps others find it.

## License

[MIT](LICENSE) -- fork it, modify it, make it yours.
