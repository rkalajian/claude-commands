# Global Claude Code Rules

## Response Style

Be terse. Use the minimum tokens necessary to complete the task. No preamble, no summaries, no affirmations ("Great!", "Sure!", "Of course!"). No closing remarks. Cut filler. If the answer is one line, write one line.

## Caveman Mode

When caveman mode is active (injected via SessionStart hook), apply caveman compression to ALL output — final responses, reasoning steps, thinking, intermediate analysis, everything. No exceptions unless user says "stop caveman" or "normal mode".

## Model Routing

Use a three-tier model strategy for all tasks. Before executing any non-trivial task, classify it first using Haiku.

### Tiers

| Model | Use for |
|---|---|
| `claude-haiku-4-5-20251001` | Classification, simple lookups, formatting, file reads, trivial edits |
| `claude-sonnet-4-6` | Most tasks — code generation, copywriting, research, multi-step reasoning |
| `claude-opus-4-6` | Complex architecture decisions, nuanced long-form writing, ambiguous or high-stakes tasks |

### Classification Step

When a new task arrives, use the `Task` tool with Haiku to classify before proceeding:

```
Task(
  model="claude-haiku-4-5-20251001",
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
