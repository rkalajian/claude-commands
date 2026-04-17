#!/bin/bash
# Plugins required for this config
REQUIRED_PLUGINS=(
  "caveman@caveman"
)

for plugin in "${REQUIRED_PLUGINS[@]}"; do
  if ! claude plugin list 2>/dev/null | grep -q "^  ❯ ${plugin}$"; then
    echo "Installing missing plugin: ${plugin}" >&2
    claude plugin install "${plugin}"
  fi
done
