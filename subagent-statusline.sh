#!/bin/bash
input=$(cat)

# For each running/idle task, emit a row showing description (which should include model)
echo "$input" | jq -r '
  .tasks[]? |
  select(.status == "running" or .status == "idle") |
  {
    id: .id,
    description: (.description // .name // "subagent"),
    status: .status,
    tokens: (.tokenCount // 0)
  } |
  @base64
' | while IFS= read -r encoded; do
  task=$(echo "$encoded" | base64 -d)
  id=$(echo "$task" | jq -r '.id')
  desc=$(echo "$task" | jq -r '.description')
  status=$(echo "$task" | jq -r '.status')
  tokens=$(echo "$task" | jq -r '.tokens')

  # Extract model from description if present (e.g. "[haiku] Do thing")
  model_badge=""
  if echo "$desc" | grep -qE '^\[haiku\]'; then
    model_badge="\033[38;5;220m[haiku]\033[0m"
    desc=$(echo "$desc" | sed 's/^\[haiku\] *//')
  elif echo "$desc" | grep -qE '^\[sonnet\]'; then
    model_badge="\033[38;5;39m[sonnet]\033[0m"
    desc=$(echo "$desc" | sed 's/^\[sonnet\] *//')
  elif echo "$desc" | grep -qE '^\[opus\]'; then
    model_badge="\033[38;5;135m[opus]\033[0m"
    desc=$(echo "$desc" | sed 's/^\[opus\] *//')
  fi

  # Status indicator
  if [ "$status" = "running" ]; then
    status_icon="⟳"
  else
    status_icon="·"
  fi

  # Token count (compact)
  tok_str=""
  if [ "$tokens" -gt 0 ] 2>/dev/null; then
    if [ "$tokens" -ge 1000 ]; then
      tok_str=" \033[2m$(echo "$tokens" | awk '{printf "%.1fk", $1/1000}')t\033[0m"
    else
      tok_str=" \033[2m${tokens}t\033[0m"
    fi
  fi

  content="${status_icon} "
  [ -n "$model_badge" ] && content="${content}${model_badge} "
  content="${content}\033[0;37m${desc}\033[0m${tok_str}"

  printf '{"id": "%s", "content": "%s"}\n' "$id" "$(echo "$content" | sed 's/"/\\"/g')"
done
