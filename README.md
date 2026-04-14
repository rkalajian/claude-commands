# ~/.claude

Personal Claude Code configuration — hooks, skills, commands, and global rules.

## Structure

```
.claude/
├── CLAUDE.md              # Global rules: response style, model routing
├── settings.json          # Permissions, hooks, status line, plugins
├── commands/              # Slash command docs (git, npm, composer workflows)
├── skills/                # Custom skills loaded by Claude Code
│   ├── buddy/             # Coding companion (claude-buddy MCP)
│   ├── github/            # GitHub PR/issue/CI workflow
│   └── tailwind-optimize/ # Convert CSS to Tailwind utility classes
└── .gitignore             # Tracks commands/, skills/, CLAUDE.md, settings.json
```

## Global Rules (CLAUDE.md)

- Terse responses, no filler or pleasantries
- Three-tier model routing: Haiku → Sonnet → Opus by task complexity
- Caveman mode injected via SessionStart hook

## Settings

Key config in `settings.json`:

| Setting | Value | Purpose |
|---|---|---|
| `refreshInterval` | 5s | Buddy status line animation |
| `alwaysThinkingEnabled` | false | No extended thinking by default |
| `enabledPlugins` | `caveman@caveman` | Caveman compression mode |
| `mcp__claude_buddy__*` | allowed | Buddy companion MCP tools |

## Hooks

| Event | Hook | Purpose |
|---|---|---|
| `SessionStart` | inline echo | Inject caveman mode system message |
| `PostToolUse(Bash)` | `react.sh` | Buddy reacts to errors/test failures/large diffs |
| `Stop` | `buddy-comment.sh` | Extracts `<!-- buddy: ... -->` comment → status line |

Buddy hooks live at `~/Code/claude-buddy/hooks/`.

## Skills

| Skill | Trigger | Does |
|---|---|---|
| `buddy` | `/buddy` or buddy's name | Show, pet, mute, rename, set personality |
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

## Plugins

- **caveman** — `JuliusBrussee/caveman` via GitHub marketplace. Ultra-compressed communication mode. `/caveman lite|full|ultra` to switch levels.

## claude-buddy

Animated coding companion in the status line. Separate repo at `~/Code/claude-buddy/`.

Species: dragon (uncommon) — Biscuit. Peak stat: CHAOS. Dump stat: DEBUGGING.
