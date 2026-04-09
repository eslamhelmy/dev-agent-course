# Lesson 02 -- The Foundation: CLAUDE.md + State Files

The brain is `CLAUDE.md` -- the master instruction file Claude Code reads at startup. The memory is a set of state files that persist between sessions.

---

## Where You Are

```
your-project/
  (empty -- we start here)
```

---

## See It: What CLAUDE.md Does

When Claude Code starts a session, it looks for a `CLAUDE.md` file in your project root. If it finds one, it reads the entire file and treats it as instructions. This is not a suggestion file. It is a directive. Whatever you write in CLAUDE.md, Claude Code will follow.

This means you can define:
- What files to read at startup
- What rules to follow when making decisions
- What to do after completing a task
- What never to do

Think of CLAUDE.md as the agent's job description. Without it, Claude Code is a general-purpose assistant. With it, Claude Code becomes your specific agent.

## See It: What State Files Do

State files are plain text files that track what the agent knows and what it has done. They live in a `.claude/` directory inside your project. The agent reads them before acting and updates them after acting.

The core state files:

| File | Purpose | Pattern |
|---|---|---|
| `tasks-active.md` | Work in progress | Read before acting, update after acting |
| `progress.txt` | Action log | Append-only, never overwrite |
| `preferences.md` | User identity and rules | Read at startup, updated when user corrects |

---

## Build It: Create the .claude Directory

Open your project in Claude Code. Every instruction from here on is a prompt you give to Claude Code.

**Intent:** Create the directory structure for agent state files.

**Prompt for Claude Code:**

```
Create a .claude/ directory in the project root with these empty files:
- tasks-active.md
- progress.txt
- preferences.md
```

**Expected output:** Three files created inside `.claude/`.

---

## Build It: Write Your CLAUDE.md

This is the most important file in the entire system. Start minimal. You will expand it in every lesson.

**Intent:** Create the master instruction file that defines agent startup behavior.

**Prompt for Claude Code:**

```
Create a CLAUDE.md file in the project root with the following content:

# Dev Agent

## Session Startup

1. Read agent state:
   - `.claude/preferences.md` -- who I am and my rules
   - `.claude/tasks-active.md` -- pending work
   - `.claude/progress.txt` -- what happened recently

2. Resume any in-progress work from `tasks-active.md`

## State Management Rules

- Read before acting -- always check current state before processing
- Update in same turn -- when you act, update the state file immediately
- Append-only logs -- progress.txt never gets overwritten

## After Task Completion

- Append one line to progress.txt with what was done and when
- Update tasks-active.md to reflect current status
```

**Expected output:** A `CLAUDE.md` file in the project root.

---

## Build It: Set Up Your Preferences

The preferences file tells the agent who you are. This matters because the agent will make decisions on your behalf, write in your voice, and interact with your tools.

**Intent:** Define your identity and basic rules for the agent.

**Prompt for Claude Code:**

```
Write .claude/preferences.md with this structure (fill in the placeholders with
my actual info based on what you know, or leave them as placeholders):

# Preferences

## Identity
- Name: [Your Name]
- Role: [Your Role]
- Timezone: [Your Timezone]

## Communication
- Default notification channel: Telegram
- Tone: Direct, technical, no fluff

## Don'ts
- Never push code without approval
- Never send messages on my behalf without approval
- Never delete files without confirmation
- Never commit secrets or credentials
```

**Expected output:** A populated `preferences.md` file.

---

## Build It: Initialize the Task Tracker

The task tracker is the agent's to-do list. It reads this file to know what needs doing. You update it when assigning work. The agent updates it when work progresses or completes.

**Intent:** Create the active task file with a starting task.

**Prompt for Claude Code:**

```
Write .claude/tasks-active.md with this content:

# Active Tasks

## TASK-001: Set up dev agent foundation
- Status: in-progress
- Priority: P1
- Created: [today's date]
- Description: Create CLAUDE.md, state files, and basic agent infrastructure
```

**Expected output:** A task file with one entry.

---

## Build It: Initialize the Progress Log

The progress log is append-only. Every action the agent takes gets one line here. This creates an audit trail you can review at any time.

**Intent:** Create the progress log with the first entry.

**Prompt for Claude Code:**

```
Append to .claude/progress.txt:

[today's date and time] -- Agent foundation created: CLAUDE.md, tasks-active.md, preferences.md, progress.txt
```

**Expected output:** One line in `progress.txt`.

---

## How to Instruct Claude Code

You just used Claude Code prompts for the first time. Here is the pattern you will use throughout this course:

**The 3-Block Prompt Pattern:**

1. **Intent** -- What you want to accomplish (one sentence)
2. **Prompt for Claude Code** -- The exact text you type into Claude Code
3. **Expected Output** -- What you should see when it works

This pattern works because Claude Code responds to clear, specific instructions. Vague prompts get vague results. Structured prompts get predictable results.

**Tips for effective Claude Code prompts:**

- State what to do, not how to think about it
- Include file paths explicitly
- Show the expected content or structure
- One action per prompt when learning; batch when confident

---

## Checkpoint

Your project should now contain: `CLAUDE.md`, `.claude/preferences.md`, `.claude/tasks-active.md`, `.claude/progress.txt`.

---

## Fork It

- **Different role?** Change preferences.md to reflect your actual job title, timezone, and tools.
- **Different notification channel?** Replace Telegram with Slack, Discord, or email in preferences.md.
- **Team agent?** Add a `team-members.md` file with names and roles. Reference it from CLAUDE.md.
- **Existing project?** You can add `.claude/` and `CLAUDE.md` to any existing repo. The agent layer sits on top of your code.

Next lesson: you add hooks to make the agent's behavior deterministic and get notifications on your phone.
