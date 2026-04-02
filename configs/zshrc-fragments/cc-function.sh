#!/bin/bash
# Claude Code launcher function (canonical source)
# Sourced from .zshrc — do not duplicate; edit here only.

unalias cc 2>/dev/null
cc() {
  echo "Checking versions..."
  local cv=$(claude --version 2>/dev/null | awk '{print $1}')
  local cl=$(npm show @anthropic-ai/claude-code version 2>/dev/null)
  if [ "$cv" = "$cl" ]; then echo "  Claude Code: v${cv} OK"
  else echo "  Claude Code: v${cv} -> v${cl} available"
    echo -n "  Update now? [y/N] "; read ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then npm i -g @anthropic-ai/claude-code@latest; fi
  fi
  # omc: pull marketplace + update plugin + ensure enabled
  local omc_market="$HOME/.claude/plugins/marketplaces/oh-my-claudecode"
  if [ -d "$omc_market/.git" ]; then
    git -C "$omc_market" pull --rebase --quiet 2>/dev/null
  fi
  local ov=$(ls -1 ~/.claude/plugins/cache/oh-my-claudecode/oh-my-claudecode 2>/dev/null | sort -V | tail -1)
  local mp_ver=$(cat "$omc_market/.claude-plugin/plugin.json" 2>/dev/null | grep '"version"' | head -1 | sed 's/.*: *"\(.*\)".*/\1/')
  if [ -n "$ov" ] && [ -n "$mp_ver" ]; then
    if [ "$ov" = "$mp_ver" ]; then echo "  omc: v${ov} OK"
    else
      echo "  omc: v${ov} -> v${mp_ver} updating..."
      claude plugins update oh-my-claudecode@oh-my-claudecode 2>/dev/null | tail -1
    fi
  elif [ -n "$ov" ]; then
    echo "  omc: v${ov}"
  fi
  if claude plugins list 2>/dev/null | grep -A2 "oh-my-claudecode@oh-my-claudecode" | grep -q "disabled"; then
    echo "  omc plugin disabled, re-enabling..."
    claude plugins enable oh-my-claudecode@oh-my-claudecode >/dev/null 2>&1
  fi
  # Usage advice before launch
  node ~/.claude/hud/usage-advice.mjs 2>/dev/null
  claude --permission-mode auto "$@" 2>/dev/null || claude --permission-mode bypassPermissions "$@"
}
alias ccrp='cc -p "utw ralplan"'
