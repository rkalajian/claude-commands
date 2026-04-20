# ~/.claude

Personal Claude Code configuration — hooks, skills, commands, and global rules.

## Installation

**Prerequisites:** [Claude Code](https://claude.ai/code) installed and authenticated.

```bash
# Back up existing config if present
mv ~/.claude ~/.claude.bak

# Clone into ~/.claude
git clone git@github.com:rkalajian/claude-commands.git ~/.claude
```

Settings, hooks, and skills load automatically when Claude Code starts.

## How to Use

**Skills** — invoke with a slash command in any Claude Code session:

| Command | What it does |
|---|---|
| `/commit` | Caveman-compressed conventional commit |
| `/ghbranch` | Create and push a branch |
| `/checkout` | Checkout branch and pull latest |
| `/pr` | Open a pull request |
| `/push` | Push and deploy verification |
| `/deliver` | Commit → push (combo) |
| `/ship` | Commit → push → PR (combo) |
| `/github` | PR review, issue management, CI status |
| `/tailwind-optimize` | Convert CSS to Tailwind utility classes |
| `/caveman` | Toggle caveman compression mode |

**Caveman mode** activates automatically on session start via the `SessionStart` hook. Change intensity with `/caveman lite|full|ultra`, or disable with `stop caveman`.

**Model routing** is automatic — Haiku classifies task complexity, then routes to Haiku / Sonnet / Opus accordingly. Override by naming a model explicitly. All `Agent` calls use `[model]`-prefixed descriptions (e.g. `[haiku] Classify task`) so the subagent statusline can display the model.

## Structure

```
.claude/
├── CLAUDE.md                  # Global rules: response style, model routing
├── settings.json              # Permissions, hooks, status line, plugins
├── statusline-command.sh      # Main status line script
├── subagent-statusline.sh     # Subagent status line (model badge + tokens)
├── ensure-plugins.sh          # Auto-installs missing plugins on SessionStart
├── commands/                  # Slash command docs (git, npm, composer workflows)
├── skills/                    # Custom skills loaded by Claude Code
│   ├── github/                # GitHub PR/issue/CI workflow
│   └── tailwind-optimize/     # Convert CSS to Tailwind utility classes
└── .gitignore                 # Tracks commands/, skills/, CLAUDE.md, settings.json, statusline scripts
```

## Global Rules (CLAUDE.md)

- Terse responses, no filler or pleasantries
- Three-tier model routing: Haiku → Sonnet → Opus by task complexity
- Caveman mode injected via SessionStart hook
- Security-conscious coding: OWASP Top 10 prevention enforced on all generated code
- WCAG 2.1 AA accessibility: semantic HTML, ARIA, keyboard nav, contrast ratios required on all frontend code

## Settings

Key config in `settings.json`:

| Setting | Value | Purpose |
|---|---|---|
| `alwaysThinkingEnabled` | true | Extended thinking always on |
| `enabledPlugins` | `caveman@caveman` | Caveman compression mode |
| `subagentStatusLine` | `subagent-statusline.sh` | Per-subagent model badge + token count |

## Hooks

| Event | Hook | Purpose |
|---|---|---|
| `SessionStart` | inline echo | Inject caveman mode system message |
| `SessionStart` | `ensure-plugins.sh` | Install missing plugins |
| `SessionStart` | pixel-agents | Session lifecycle event |
| `SessionEnd` | pixel-agents | Session lifecycle event |
| `Stop` | pixel-agents | Turn stop event |
| `PermissionRequest` | pixel-agents | Permission gate event |
| `Notification` | pixel-agents | Notification event |
| `UserPromptSubmit` | pixel-agents | Pre-prompt event |
| `PreToolUse` | pixel-agents | Before tool execution |
| `PostToolUse` | pixel-agents | After tool success |
| `PostToolUseFailure` | pixel-agents | After tool failure |
| `SubagentStart` | pixel-agents | Subagent lifecycle event |
| `SubagentStop` | pixel-agents | Subagent lifecycle event |

Pixel-agents hooks run via `node ~/.pixel-agents/hooks/claude-hook.js`. The `~/.pixel-agents/` directory is **external config — not tracked by this repo**. Install pixel-agents separately; add the `node ~/.pixel-agents/hooks/claude-hook.js` permission to your local `settings.local.json`.

## Skills

| Skill | Trigger | Does |
|---|---|---|
| `github` | `/github`, `/pr`, `/issue` | PR create/review, issue management, CI status |
| `tailwind-optimize` | `/tailwind-optimize` | Convert CSS → Tailwind utility classes |

## Commands

Workflow reference docs in `commands/` — used by Claude as slash commands:

### Atomic
- `commit.md` — commit formatting and staging rules
- `ghbranch.md` — branch naming and creation
- `checkout.md` — checkout branch and pull latest
- `pr.md` — PR workflow and checklist
- `push.md` — push/deploy verification
- `npm.md` — safe npm install/update/remove
- `composer.md` — safe Composer install/update/remove

### Combo
- `deliver.md` — commit → push
- `ship.md` — commit → push → PR

## Status Line

### Main (`statusline-command.sh`)

Order left→right:

| Segment | Content |
|---|---|
| Caveman badge | Active caveman mode level (from plugin) |
| Model | Current Claude model in use |
| Dir | Basename of current working directory |
| Git | Branch name + dirty marker (robbyrussell style) |
| Node/npm | `vX.Y.Z/npm@X.Y.Z` |

### Subagent (`subagent-statusline.sh`)

Shown per running subagent. Reads `[model]` prefix from the Agent description field:

| Segment | Content |
|---|---|
| Status icon | `⟳` running / `·` idle |
| Model badge | `[haiku]` (yellow) / `[sonnet]` (blue) / `[opus]` (purple) |
| Description | Agent description with model prefix stripped |
| Tokens | Compact token count (e.g. `1.4kt`) |

Requires Agent calls to follow the `[model] Description` naming convention (enforced in `CLAUDE.md`).

## Plugins

- **caveman** — `JuliusBrussee/caveman` via GitHub marketplace. Ultra-compressed communication mode. `/caveman lite|full|ultra` to switch levels.

To add a required plugin, append its `name@marketplace` identifier to `REQUIRED_PLUGINS` in `ensure-plugins.sh`. It will be installed automatically on next session start.

## External Tools

### pixel-agents

Event-driven Node.js hook runner that fires on all Claude Code lifecycle events. Config lives at `~/.pixel-agents/` — **not tracked by this repo**.

```
~/.pixel-agents/
├── layout.json          # Agent layout config
└── hooks/
    └── claude-hook.js   # Hook entry point (called by Claude Code hooks)
```

Install pixel-agents independently. After install, add to `settings.local.json` (not committed):

```json
{
  "permissions": {
    "allow": [
      "Bash(node ~/.pixel-agents/hooks/claude-hook.js)"
    ]
  }
}
```
