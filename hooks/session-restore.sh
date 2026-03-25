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

exit 0
