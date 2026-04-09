# Lesson 10 — Access Your Agent from Anywhere

Your agent runs on your machine. But you're not always at your machine. This lesson sets up phone access so you can check on your agent, approve permissions, and read reports from anywhere.

## Where You Are

```
.claude/
├── CLAUDE.md
├── preferences.md
├── error-log.md
├── learnings.md
├── auto-resolver.md
├── priority-map.md
├── tasks-active.md
├── tasks-completed.md
├── progress.txt
├── cron-jobs.json
├── failed-jobs.log
├── hooks/
│   ├── stop-telegram.sh
│   └── (settings.local.json configured)
└── skills/
    ├── daily-planner/
    ├── pr-reviewer/
    ├── git-reviewer/
    ├── standup-generator/
    ├── meeting-ingest/
    └── heartbeat/
```

You have a full agent with 6 skills, hooks that notify your phone, and a heartbeat that self-heals. But if your terminal closes, the agent dies. And if you're away from your desk, you can't interact with it.

## What You Are Adding

Phone access to your agent via SSH using tmux, Tailscale, and a mobile SSH client.

---

## The Reliable Stack: tmux + Tailscale + Termius

Three tools, 10-minute setup:

| Tool | What It Does | Why |
|------|-------------|-----|
| **tmux** | Keeps your terminal session alive after disconnect | Agent survives laptop close, SSH drop, even reboot (with systemd) |
| **Tailscale** | Mesh VPN — your devices find each other anywhere | SSH from phone to laptop without port forwarding, static IPs, or VPN servers |
| **Termius** | Mobile SSH client | Check on your agent from your phone |

---

## Step 1: Install tmux

```bash
brew install tmux            # macOS (or: sudo apt install tmux)
tmux new -s agent            # create a named session
# Ctrl+B then D to detach
tmux attach -t agent         # reattach from anywhere
```

tmux keeps your agent session alive after disconnect -- close the terminal, reattach later, context intact.

---

## Step 2: Install Tailscale

```bash
brew install tailscale       # macOS (or: curl -fsSL https://tailscale.com/install.sh | sh)
sudo tailscale up            # authenticate via browser link
```

Your machine gets a Tailscale IP (e.g., `100.x.y.z`) reachable from any device on your Tailscale network.

---

## Step 3: Install Termius on Your Phone

Download Termius from App Store / Play Store. Add a host using your Tailscale IP, your username, and SSH key auth. Connect and run `tmux attach -t agent`.

---

## Step 4: Survive Reboots (Optional)

If your machine restarts, tmux dies. Fix it with a startup service.

**Intent:** tmux agent session starts automatically on boot.

**Prompt for Claude Code:**
```
Create a launchd plist (macOS) or systemd service (Linux) that starts a tmux session named "agent" on boot. The session should run as my user, not root. Include the full file content and the command to install it.

Rules:
- macOS: write to ~/Library/LaunchAgents/com.agent.tmux.plist
- Linux: write to ~/.config/systemd/user/agent-tmux.service
- Only create the file for my current OS
- Show how to enable it
```

**Expected output:** A service file that auto-starts tmux on boot. Your agent session is now immortal.

---

## The Full Flow

```
Your Phone (Termius)
  → Tailscale (encrypted tunnel)
    → Your Machine (SSH)
      → tmux session "agent"
        → Claude Code (running, context intact)
          → 6 skills on cron
          → Telegram notifications to your phone
          → Heartbeat self-healing every 2h
```

---

## Checkpoint

You now have: tmux keeping your agent session alive, Tailscale making your machine reachable from anywhere, and a mobile SSH client for phone access. No new `.claude/` files -- this lesson is about infrastructure around the agent.

---

Next lesson: you put it all together, review the complete system, and ship it.
