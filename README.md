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
| `/pr` | Open a pull request |
| `/push` | Push and deploy verification |
| `/github` | PR review, issue management, CI status |
| `/tailwind-optimize` | Convert CSS to Tailwind utility classes |
| `/caveman` | Toggle caveman compression mode |

**Caveman mode** activates automatically on session start via the `SessionStart` hook. Change intensity with `/caveman lite|full|ultra`, or disable with `stop caveman`.

**Model routing** is automatic — Haiku classifies task complexity, then routes to Haiku / Sonnet / Opus accordingly. Override by naming a model explicitly.

## Structure

```
.claude/
├── CLAUDE.md                  # Global rules: response style, model routing
├── settings.json              # Permissions, hooks, status line, plugins
├── statusline-command.sh      # Custom status line script
├── commands/                  # Slash command docs (git, npm, composer workflows)
├── skills/                    # Custom skills loaded by Claude Code
│   ├── github/                # GitHub PR/issue/CI workflow
│   └── tailwind-optimize/     # Convert CSS to Tailwind utility classes
└── .gitignore                 # Tracks commands/, skills/, CLAUDE.md, settings.json, statusline-command.sh
```

## Global Rules (CLAUDE.md)

- Terse responses, no filler or pleasantries
- Three-tier model routing: Haiku → Sonnet → Opus by task complexity
- Caveman mode injected via SessionStart hook

## Settings

Key config in `settings.json`:

| Setting | Value | Purpose |
|---|---|---|
| `alwaysThinkingEnabled` | false | No extended thinking by default |
| `enabledPlugins` | `caveman@caveman` | Caveman compression mode |

## Hooks

| Event | Hook | Purpose |
|---|---|---|
| `SessionStart` | inline echo | Inject caveman mode system message |

## Skills

| Skill | Trigger | Does |
|---|---|---|
| `github` | `/github`, `/pr`, `/issue` | PR create/review, issue management, CI status |
| `tailwind-optimize` | `/tailwind-optimize` | Convert CSS → Tailwind utility classes |

## Commands

Workflow reference docs in `commands/` — used by Claude as slash commands:

- `commit.md` — commit formatting and staging rules
- `ghbranch.md` — branch naming and creation
- `pr.md` — PR workflow and checklist
- `push.md` — push/deploy verification
- `npm.md` — safe npm install/update/remove
- `composer.md` — safe Composer install/update/remove

## Status Line

Custom status line via `statusline-command.sh`. Order left→right:

| Segment | Content |
|---|---|
| Caveman badge | Active caveman mode level (from plugin) |
| Model | Current Claude model in use |
| Dir | Basename of current working directory |
| Git | Branch name + dirty marker (robbyrussell style) |
| Node/npm | `vX.Y.Z/npm@X.Y.Z` |

## Plugins

- **caveman** — `JuliusBrussee/caveman` via GitHub marketplace. Ultra-compressed communication mode. `/caveman lite|full|ultra` to switch levels.
