#!/bin/bash
# sync-to-vault.sh - One-way sync: repo/commands/ -> vault/commands/
# Only syncs 9 retrospective commands. General commands untouched.
# Usage: bash ~/.dev-retrospective/scripts/sync-to-vault.sh

set -euo pipefail

REPO_ROOT="$HOME/.dev-retrospective"

# Source vault detection
source "$REPO_ROOT/scripts/vault-detect.sh"

VAULT=$(find_vault)
if [[ -z "$VAULT" ]]; then
  echo "[vault-sync] Vault not found, skipping sync"
  exit 0
fi

VAULT_CMDS="$VAULT/$VAULT_CMDS_SUBDIR"
REPO_CMDS="$REPO_ROOT/commands"

# Ensure vault commands directory exists
if [[ ! -d "$VAULT_CMDS" ]]; then
  echo "[vault-sync] Vault commands directory not found: $VAULT_CMDS"
  exit 0
fi

# 9 retrospective commands to sync
RETRO_CMDS="session-log dev-daily dev-weekly dev-monthly dev-checkin dev-consult dev-radar dev-inbox dev-setup"

SYNCED=0
SKIPPED=0
MISSING=0

for cmd in $RETRO_CMDS; do
  SRC="$REPO_CMDS/${cmd}.md"
  DST="$VAULT_CMDS/${cmd}.md"

  if [[ ! -f "$SRC" ]]; then
    MISSING=$((MISSING + 1))
    echo "  [WARN] Source not found: $SRC"
    continue
  fi

  # Compare: skip if identical
  if [[ -f "$DST" ]] && diff -q "$SRC" "$DST" >/dev/null 2>&1; then
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  # Copy (different or missing in vault)
  cp "$SRC" "$DST"
  SYNCED=$((SYNCED + 1))
  echo "  Updated: ${cmd}.md"
done

echo "[vault-sync] Synced $SYNCED/9 commands to vault ($SKIPPED unchanged, $MISSING missing)"
