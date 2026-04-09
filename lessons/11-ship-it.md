# Lesson 11 -- Ship It

You built the entire system. Nine lessons, six skills, a learning system, hooks, failure handling, and a self-healing heartbeat. This lesson is not about building anything new. It is about understanding what you built, knowing how to extend it, and deploying it for real.

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
    cron-jobs.json                   # 7 jobs
    failed-jobs.log
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
        SKILL.md
      heartbeat/
        SKILL.md
```

This is the complete system. No external database. No cloud service beyond the APIs your skills call. Everything lives in files you can read, edit, and version-control.

---

## The Universal Pattern

Every skill you built follows the same cycle:

```
Trigger --> Read State --> Decide --> Act --> Verify --> Update State --> Report
```

| Step | Daily Planner | PR Reviewer | Meeting Ingest | Heartbeat |
|---|---|---|---|---|
| **Trigger** | 5:33 PM cron | 3x daily cron | 6:37 PM cron | Every 2h cron |
| **Read State** | tasks, progress | preferences (repos) | preferences, tasks | everything |
| **Decide** | Score the day | Flag risky PRs | Extract vs skip | Healthy vs degraded |
| **Act** | Generate report | Query GitHub | Parse transcripts | Run all checks |
| **Verify** | Report has content | All repos scanned | No duplicates | No false positives |
| **Update State** | progress.txt | progress.txt, tasks | tasks, progress | crons, failed-jobs |
| **Report** | Daily report file | PR digest file | Meeting notes | Health report |

Any new skill slots in without modifying the existing architecture.

---

## How to Add a New Skill

- Create `.claude/skills/{name}/SKILL.md` with four sections (Input, Process, Output, State Update) and add a cron entry to `cron-jobs.json`.
- Add the skill to the heartbeat's verification list so it gets health-checked.
- Test manually first ("Run the {name} skill"), then monitor `progress.txt` and `failed-jobs.log` for the first 3 scheduled runs.

---

## Deployment Phases

- **Phase 1 -- Prototype (1-3 days):** Run skills manually, fix issues interactively, validate output quality.
- **Phase 2 -- Reliable (1-2 weeks):** Enable cron schedules, run the heartbeat, monitor failed-jobs.log daily, tune thresholds.
- **Phase 3 -- Production (ongoing):** Agent runs in a persistent session with heartbeat renewing crons and Telegram keeping you informed.

---

## Component Swap Table

Everything in this system is replaceable. Here are the most common swaps:

| Component | Default | Alternatives |
|---|---|---|
| **Notifications** | Telegram | Slack webhook, Discord webhook, email, Pushover, ntfy |
| **Email** | Gmail (MCP) | Outlook/Graph API, Fastmail, ProtonMail bridge |
| **Calendar** | Google Calendar | Outlook Calendar, iCal, Fantastical |
| **Meeting Notes** | Granola | Otter.ai, Teams transcripts, Fireflies, manual upload |
| **Git Hosting** | GitHub (gh CLI) | GitLab (glab), Bitbucket, Azure DevOps |
| **Persistent Session** | tmux | screen, Zellij, VS Code remote |
| **Remote Access** | Tailscale | Cloudflare Tunnel, ngrok, WireGuard |
| **Mobile SSH** | Termius | Blink Shell, Prompt 3, JuiceSSH |

To swap a component: update the relevant skill's Process section and preferences.md. The architecture stays the same.

---

## Skill Ideas

Example skills you can build using the same pattern (skill file, cron entry, state interactions, heartbeat registration):

- **Deployment Monitor** -- Watch production deploys, compare error rates before/after, alert on regressions.
- **Dependency Auditor** -- Weekly scan of dependencies for security advisories and outdated packages.
- **Sprint Health** -- Pull Jira/Linear data, calculate velocity, flag blocked items.

---

## The Compound Effect

Your agent gets better over time. Here is why:

**Week 1:** You correct the agent 10 times. Each correction is immediately written to preferences.md, error-log.md, or learnings.md.

**Week 2:** The agent reads those files at startup. It avoids the mistakes from week 1. You correct it 6 times. Each correction is recorded.

**Week 4:** The agent knows your preferences, avoids 15+ past mistakes, and has accumulated 20+ patterns. Corrections drop to 2-3 per week.

**Month 2:** The learning loop has promoted the most common patterns to CLAUDE.md. The agent operates almost independently. You mostly review output rather than correct it.

This is the compound effect of inline learning. Every correction makes every future session better. The investment is front-loaded. The returns are permanent.

---

## Final Checklist

- [ ] CLAUDE.md has complete session startup instructions
- [ ] All 6 skills have SKILL.md files with Input, Process, Output, State Update
- [ ] cron-jobs.json has entries for all scheduled skills and heartbeat is enabled
- [ ] Telegram notifications and permission gate hooks work
- [ ] All state files are committed to git (except secrets)

---

## What You Built

Across 10 lessons you created ~20 files -- CLAUDE.md, state files, hooks, 6 skills, cron scheduling, failure handling, and a self-healing heartbeat -- a complete autonomous agent running on your machine with zero external services beyond the APIs your skills call.

---

## Fork It

This is not a product. It is a pattern. Fork it for your workflow:

- **Start small.** Pick the 2 skills that save you the most time. Disable the rest.
- **Tune aggressively.** The default thresholds are starting points. Adjust them after the first week based on your actual signal-to-noise ratio.
- **Share skill files.** Skills are portable. A teammate can copy your `pr-reviewer/SKILL.md` into their `.claude/skills/` and it works.
- **Version everything.** Commit `.claude/` to git. Your agent's configuration is part of your codebase.
- **Review weekly.** Spend 10 minutes reading learnings.md and failed-jobs.log. This is where you find the biggest improvements.

You have the architecture. You have the patterns. Now make it yours.
