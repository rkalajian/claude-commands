#!/bin/bash
input=$(cat)
model=$(echo "$input" | jq -r '.model.display_name // empty')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // empty')

caveman_badge=$(bash "/Users/rebel/.claude/plugins/cache/caveman/caveman/600e8efcd6ac/hooks/caveman-statusline.sh" < /dev/null 2>/dev/null)

# Current dir (basename)
dir_part=""
if [ -n "$cwd" ]; then
  dir_part=$(basename "$cwd")
fi

# Git branch + dirty status (robbyrussell style)
git_part=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    if git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null | grep -q .; then
      git_part="\033[1;34mgit:(\033[0;31m${branch}\033[1;34m) \033[0;33m✗\033[0m"
    else
      git_part="\033[1;34mgit:(\033[0;31m${branch}\033[1;34m)\033[0m"
    fi
  fi
fi

# Node + npm versions
node_part=""
node_ver=$(node --version 2>/dev/null)
npm_ver=$(npm --version 2>/dev/null)
if [ -n "$node_ver" ] && [ -n "$npm_ver" ]; then
  node_part="\033[0;32m${node_ver}\033[0m/\033[0;32mnpm@${npm_ver}\033[0m"
elif [ -n "$node_ver" ]; then
  node_part="\033[0;32m${node_ver}\033[0m"
fi

out=""
[ -n "$caveman_badge" ] && out="$caveman_badge "
[ -n "$model" ] && out="${out}\033[38;5;39m[${model}]\033[0m "
[ -n "$dir_part" ] && out="${out}\033[0;36m${dir_part}\033[0m "
[ -n "$git_part" ] && out="${out}${git_part} "
[ -n "$node_part" ] && out="${out}${node_part}"

[ -n "$out" ] && printf "$out"
