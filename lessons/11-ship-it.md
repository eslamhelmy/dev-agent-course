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

The pattern never changes. Only the trigger and the action differ. This is what makes the system composable. Any new skill slots in without modifying the existing architecture.

---

## How to Add a New Skill

Six steps. Every time.

**Step 1: Create the skill file.**
Create `.claude/skills/{name}/SKILL.md` with the four sections: Input, Process, Output, State Update. Follow the template from any existing skill.

**Step 2: Add a cron entry.**
Add an entry to `cron-jobs.json` with a unique ID, schedule, and reference to the skill file.

**Step 3: Define state interactions.**
Decide which state files the skill reads and writes. Add any new state files if needed.

**Step 4: Register with the heartbeat.**
Add the new skill file to the heartbeat's verification list so it gets health-checked.

**Step 5: Test manually.**
Run the skill by hand: "Run the {name} skill." Fix any issues before letting it run on a schedule.

**Step 6: Monitor the first 3 runs.**
Watch progress.txt and failed-jobs.log after the first few scheduled runs. Adjust thresholds and error handling as needed.

---

## Deployment Phases

Do not go from zero to 7 cron jobs overnight. Deploy in phases.

### Phase 1: Prototype (You are here)
- Run skills manually with "Run the X skill"
- Fix issues interactively
- Validate output quality
- Duration: 1-3 days

### Phase 2: Reliable
- Enable cron schedules
- Run the heartbeat
- Monitor failed-jobs.log daily
- Tune thresholds (stale task days, PR size limits, triage buckets)
- Duration: 1-2 weeks

### Phase 3: Production
- Agent runs in a persistent session (see Lesson 10)
- Heartbeat renews crons automatically
- Telegram notifications keep you informed
- Weekly review of learnings.md to see improvement
- Duration: ongoing

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

## Skill Ideas for Different Workflows

Here are skills you can build using the patterns you learned:

**For backend developers:**
- **Deployment Monitor** -- Watch production deploys, compare error rates before/after, alert on regressions.
- **Dependency Auditor** -- Weekly scan of dependencies for security advisories and outdated packages.
- **Database Migration Reviewer** -- Flag risky migrations (data loss, long locks, missing rollbacks).

**For frontend developers:**
- **Bundle Size Tracker** -- Monitor build output size across commits, flag significant increases.
- **Lighthouse Watcher** -- Run Lighthouse audits on key pages, track scores over time.
- **Design System Drift** -- Detect components that deviate from the design system tokens.

**For team leads:**
- **Sprint Health** -- Pull Jira/Linear data, calculate velocity, flag blocked items.
- **Review Turnaround** -- Track how long PRs wait for review, nudge reviewers.
- **Onboarding Buddy** -- Curate resources and check-ins for new team members.

**For DevOps/SRE:**
- **Deployment Monitor** -- Watch production deploys, compare error rates before/after, alert on regressions.
- **Incident Tracker** -- Pull production incidents from Jira, classify by root cause, track MTTR trends.
- **Runbook Executor** -- Follow runbook steps automatically for known incident types.

Each of these follows the same pattern: skill file, cron entry, state interactions, heartbeat registration.

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

Before you call this agent production-ready, verify:

- [ ] CLAUDE.md has complete session startup instructions
- [ ] All 6 skills have SKILL.md files with Input, Process, Output, State Update
- [ ] cron-jobs.json has entries for all scheduled skills
- [ ] Heartbeat is enabled and checks all other skills
- [ ] failed-jobs.log exists and is writable
- [ ] Telegram notifications work (test with the stop hook)
- [ ] Permission gate blocks dangerous operations
- [ ] preferences.md has your actual identity and repos
- [ ] auto-resolver.md reflects your actual autonomy boundaries
- [ ] All state files are committed to git (except secrets)

---

## What You Built

| Lesson | What You Added | File Count |
|---|---|---|
| 02 | CLAUDE.md, state files | 4 files |
| 03 | Hooks, settings | 3 files |
| 04 | Learning system, autonomy | 3 files + updated CLAUDE.md |
| 05 | Daily planner, scheduling | 4 files |
| 06 | PR reviewer | 1 skill + cron update |
| 07 | Git reviewer, standup generator | 2 skills + cron update |
| 08 | Meeting ingest, failure handling | 1 skill + 1 log + cron update |
| 09 | Heartbeat | 1 skill + cron update |

Total: ~20 files. Zero external services beyond what your skills call. A complete autonomous agent running on your machine.

---

## Connecting to Anything: MCP Servers

Every skill so far uses tools Claude Code already has -- file access, git, shell commands. But your agent can connect to ANY external system through MCP (Model Context Protocol) servers.

Examples of what MCPs unlock:

| MCP | What Your Agent Can Do |
|-----|----------------------|
| **Jira / Linear** | Read tickets, update status, comment on issues |
| **Notion** | Write meeting notes, update databases, create pages |
| **Slack / Teams** | Read messages, post updates, send notifications |
| **Gmail / Outlook** | Search emails, read threads, draft replies |
| **GitHub** | Beyond git -- manage issues, PRs, releases, actions |
| **Databases** | Query your DB directly from a skill |
| **Custom APIs** | Build your own MCP to connect to internal tools (e.g., a Log Analytics MCP that queries Azure Monitor, or a deployment MCP that checks your CI/CD pipeline) |

You configure MCPs in `.mcp.json` at the project root:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": { "GITHUB_TOKEN": "..." }
    },
    "notion": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-notion"],
      "env": { "NOTION_API_KEY": "..." }
    }
  }
}
```

Each MCP gives the agent new tools it can call inside any skill. The skill pattern does not change -- you still write a SKILL.md with Input, Process, Output, State Update. The tools just get more powerful.

Building custom MCPs is its own deep topic and is not covered in this course. But know that the architecture you built here (skills + state files + hooks + cron + heartbeat) works identically with MCP-connected tools. When you're ready to connect your agent to Jira, your internal APIs, or your monitoring stack, the pattern is the same -- you just add an MCP server and reference its tools in your skill's Process section.

---

## Fork It

This is not a product. It is a pattern. Fork it for your workflow:

- **Start small.** Pick the 2 skills that save you the most time. Disable the rest.
- **Tune aggressively.** The default thresholds are starting points. Adjust them after the first week based on your actual signal-to-noise ratio.
- **Share skill files.** Skills are portable. A teammate can copy your `pr-reviewer/SKILL.md` into their `.claude/skills/` and it works.
- **Version everything.** Commit `.claude/` to git. Your agent's configuration is part of your codebase.
- **Review weekly.** Spend 10 minutes reading learnings.md and failed-jobs.log. This is where you find the biggest improvements.

You have the architecture. You have the patterns. Now make it yours.
