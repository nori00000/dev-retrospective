#!/bin/bash
# vault-detect.sh - Shared Obsidian vault auto-detection function
# Source this file in hooks and scripts:
#   source "$HOME/.dev-retrospective/scripts/vault-detect.sh"
#   VAULT=$(find_vault)
#
# Override: export DEV_RETRO_VAULT="/path/to/vault"
# Cache: stored at ~/.dev-retrospective/.vault-path (24h TTL)

# Vault subdirectory constants
VAULT_CMDS_SUBDIR="00. Inbox/03. AI Agent/scripts/claude-system/commands"
VAULT_SESSIONS_SUBDIR="00. Inbox/03. AI Agent/sessions"
VAULT_SCRIPTS_SUBDIR="00. Inbox/03. AI Agent/scripts"

find_vault() {
  # Priority 1: Explicit environment variable
  if [[ -n "${DEV_RETRO_VAULT:-}" ]] && [[ -d "$DEV_RETRO_VAULT" ]]; then
    echo "$DEV_RETRO_VAULT"
    return 0
  fi

  # Priority 2: Cached path (< 24h old)
  local CACHE_FILE="$HOME/.dev-retrospective/.vault-path"
  if [[ -f "$CACHE_FILE" ]]; then
    local CACHED
    CACHED=$(cat "$CACHE_FILE")
    local FILE_MOD
    # macOS stat vs Linux stat
    if stat -f %m "$CACHE_FILE" >/dev/null 2>&1; then
      FILE_MOD=$(stat -f %m "$CACHE_FILE")
    else
      FILE_MOD=$(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)
    fi
    local NOW
    NOW=$(date +%s)
    local AGE=$(( NOW - FILE_MOD ))
    if [[ $AGE -lt 86400 ]] && [[ -d "$CACHED" ]]; then
      echo "$CACHED"
      return 0
    fi
  fi

  # Priority 3: Search for .obsidian/ directory
  local SEARCH_ROOTS=()
  case "$(uname -s)" in
    Darwin)
      SEARCH_ROOTS=("$HOME/Documents" "$HOME/Library/Mobile Documents")
      ;;
    Linux)
      SEARCH_ROOTS=("$HOME/Documents" "$HOME/Dropbox" "$HOME")
      ;;
    *)
      # Unsupported platform for search (Windows uses PowerShell version)
      echo ""
      return 1
      ;;
  esac

  local FOUND_VAULTS=()
  for root in "${SEARCH_ROOTS[@]}"; do
    [[ -d "$root" ]] || continue
    while IFS= read -r obsidian_dir; do
      local vault_dir
      vault_dir=$(dirname "$obsidian_dir")
      # Validate: must contain our specific subdirectory
      if [[ -d "$vault_dir/$VAULT_CMDS_SUBDIR" ]]; then
        FOUND_VAULTS+=("$vault_dir")
      fi
    done < <(find "$root" -maxdepth 3 -name ".obsidian" -type d 2>/dev/null)
  done

  if [[ ${#FOUND_VAULTS[@]} -eq 0 ]]; then
    echo "" >&2
    echo "[vault-detect] Vault not found. Set DEV_RETRO_VAULT env var to specify." >&2
    echo ""
    return 1
  fi

  # Prefer vault with "Obsidian" in name
  local RESULT="${FOUND_VAULTS[0]}"
  for v in "${FOUND_VAULTS[@]}"; do
    if [[ "$v" == *"Obsidian"* ]]; then
      RESULT="$v"
      break
    fi
  done

  # Cache result
  mkdir -p "$(dirname "$CACHE_FILE")"
  echo "$RESULT" > "$CACHE_FILE"

  echo "$RESULT"
  return 0
}
