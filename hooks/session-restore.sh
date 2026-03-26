#!/bin/bash
# Session Start Hook - Restore previous session context

# Read hook input from stdin
read -r hook_input

# Check for last session info
BACKUP_DIR="$HOME/.claude/session-backups"
LAST_SESSION="$BACKUP_DIR/last_session.json"

if [ -f "$LAST_SESSION" ]; then
    # Export session info as environment variables if CLAUDE_ENV_FILE is set
    if [ -n "$CLAUDE_ENV_FILE" ]; then
        last_cwd=$(jq -r '.cwd // ""' "$LAST_SESSION")
        last_branch=$(jq -r '.git_branch // ""' "$LAST_SESSION")
        last_time=$(jq -r '.timestamp // ""' "$LAST_SESSION")

        echo "export LAST_SESSION_CWD='$last_cwd'" >> "$CLAUDE_ENV_FILE"
        echo "export LAST_SESSION_BRANCH='$last_branch'" >> "$CLAUDE_ENV_FILE"
        echo "export LAST_SESSION_TIME='$last_time'" >> "$CLAUDE_ENV_FILE"
    fi
fi

# === 다른 머신의 마지막 세션 정보 ===
MACHINES_DIR="$HOME/.dev-retrospective/data/machines"
if [ -d "$MACHINES_DIR" ] && [ -n "$CLAUDE_ENV_FILE" ]; then
  CURRENT_MACHINE=$(hostname -s)
  OTHER_SESSIONS=""
  for mdir in "$MACHINES_DIR"/*/; do
    mname=$(basename "$mdir")
    [ "$mname" = "$CURRENT_MACHINE" ] && continue
    mfile="$mdir/last_session.json"
    [ -f "$mfile" ] || continue
    read m_project m_time m_unpushed <<< $(python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('project','?'), d.get('timestamp','?'), d.get('unpushed_commits',0))
" < "$mfile" 2>/dev/null)
    OTHER_SESSIONS="${OTHER_SESSIONS}${mname}:${m_project}:${m_time}:${m_unpushed};"
  done
  echo "export OTHER_MACHINE_SESSIONS=\"$OTHER_SESSIONS\"" >> "$CLAUDE_ENV_FILE"
fi

exit 0
