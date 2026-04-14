---
name: github
description: "GitHub workflow helper — create PRs, review code, manage issues, check CI status. Use when user says /github, /pr, /issue, or asks about GitHub operations."
argument-hint: "[pr|pr create|review <PR#>|issue|issue create|status|diff]"
allowed-tools: Bash, Read, Glob, Grep
---

# GitHub Skill

Handle GitHub operations for the current repository using the `gh` CLI.

## Command Routing

Based on `$ARGUMENTS`:

| Input | Action |
|-------|--------|
| *(empty)* or `status` | Show branch status, open PRs, recent CI |
| `pr` or `pr create` | Create PR from current branch |
| `pr list` | List open PRs |
| `pr <number>` | Show PR details and diff summary |
| `review` or `review <number>` | Review a PR — summarize changes, flag concerns |
| `issue` or `issue create` | Create a new issue |
| `issue list` | List open issues |
| `diff` | Summarize uncommitted changes for review |
| `merge <number>` | Merge a PR (confirm first) |

## Behavior

### `status` (default)
Run in parallel:
- `git status` + `git log --oneline -5`
- `gh pr list --state open --limit 5`
- `gh run list --limit 3`

Report: current branch, uncommitted changes, open PRs, last CI run status.

### `pr create`
1. `git log main..HEAD --oneline` — summarize commits
2. `git diff main...HEAD --stat` — file scope
3. Draft PR title (≤70 chars) + body with Summary + Test plan
4. Confirm with user before running `gh pr create`
5. Use HEREDOC for body

### `review <number>`
1. `gh pr view <number>` — metadata
2. `gh pr diff <number>` — full diff
3. Summarize: what changed, why (from PR description), concerns or suggestions
4. Use caveman-review style: terse, location + problem + fix per issue

### `issue create`
1. Ask user for title + description if not in `$ARGUMENTS`
2. Suggest labels based on content (bug / enhancement / design / content)
3. Confirm before `gh issue create`

### `diff`
1. `git diff` (unstaged) + `git diff --cached` (staged)
2. Terse summary: files changed, what changed, any concerns

## Project Context

This is **Throw-Yo** — WooCommerce storefront, WordPress child theme.
- Repo branch: `main`
- Build required before commit: `npm run build` in `wp-content/themes/throwyo-storefront/`
- Never push to `main` directly without confirming with user
- PR descriptions should mention if CSS/JS was rebuilt

## Output Style

Match the active caveman mode if set. Default to terse + technical.
Always show the PR/issue URL when created.
