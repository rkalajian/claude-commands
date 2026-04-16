# Global Claude Code Rules

## Response Style

Be terse. Use the minimum tokens necessary to complete the task. No preamble, no summaries, no affirmations ("Great!", "Sure!", "Of course!"). No closing remarks. Cut filler. If the answer is one line, write one line.

Extended thinking is enabled. Think silently — never narrate, announce, or reference the thinking process in responses. Output only conclusions and actions.

## Caveman Mode

When caveman mode is active (injected via SessionStart hook), apply caveman compression at **ultra** level to ALL output — final responses, reasoning steps, thinking, intermediate analysis, everything. No exceptions unless user says "stop caveman" or "normal mode". Use `/caveman lite|full|ultra` to change level.

## Model Routing

Use a three-tier model strategy for all tasks. Before executing any non-trivial task, classify it first using Haiku.

### Tiers

| Model | Use for |
|---|---|
| `haiku` (`claude-haiku-4-5-20251001`) | Classification, simple lookups, formatting, file reads, trivial edits |
| `sonnet` (`claude-sonnet-4-6`) | Most tasks — code generation, copywriting, research, multi-step reasoning |
| `opus` (`claude-opus-4-6`) | Complex architecture decisions, nuanced long-form writing, ambiguous or high-stakes tasks |

### Classification Step

When a new task arrives, use the `Agent` tool with Haiku to classify before proceeding:

```
Agent(
  model="haiku",
  description="[haiku] Classify task complexity",
  prompt="""
Classify the complexity of this task. Respond with ONLY one word: simple, medium, or complex.

Rules:
- simple: single-step, no reasoning required, formatting/lookup/trivial edits
- medium: multi-step but well-defined, standard code gen, typical copywriting
- complex: ambiguous goals, architecture-level decisions, nuanced judgment calls, long-form strategy

Task: {TASK_DESCRIPTION}
"""
)
```

### Routing Rules

- `simple` → use Haiku
- `medium` → use Sonnet (default)
- `complex` → use Opus

### Overrides

- If the user explicitly names a model, skip classification and use that model.
- If a project-level `CLAUDE.md` specifies a model for certain task types, that takes precedence.

### Notes

- When in doubt, route to Sonnet — it handles the vast majority of tasks well.
- Do not route to Opus based on length alone; length ≠ complexity.
- Classification itself always uses Haiku regardless of task complexity.
- **Always prefix `Agent` descriptions with `[haiku]`, `[sonnet]`, or `[opus]`** matching the model used. This drives the subagent statusline model display. Example: `description="[sonnet] Generate migration script"`.

### Aggressive Subagent Delegation

Spin off subagents frequently. Do not inline work that can be routed to a cheaper or more appropriate model.

**Default posture:** Before doing any non-trivial subtask inline, ask "Could this be a subagent?" If yes, delegate.

Tasks to always delegate:
- File reads and searches → Haiku
- Codebase exploration → Explore agent
- Classification → Haiku
- Code generation → Sonnet or Opus per complexity
- Research / web fetch → Sonnet

Only keep work inline when the subagent cannot receive the necessary conversation context.
