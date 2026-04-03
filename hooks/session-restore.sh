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

# === Homelab Orchestration 핸드오프 자동 로드 ===
ORCH_REPO="$HOME/projects/homelab-orchestration"
MACHINE=$(hostname -s | tr '[:upper:]' '[:lower:]')

if [ -d "$ORCH_REPO/.git" ]; then
  # 조용히 최신 pull
  cd "$ORCH_REPO" && git pull --quiet --rebase origin main 2>/dev/null

  # 이 머신의 태스크 파일 찾기
  TASK_FILE=""
  case "$MACHINE" in
    *m4-studio*|*mac-studio*) TASK_FILE="tasks/m4-studio.md" ;;
    *m4-air*|*macbook-air*)   TASK_FILE="tasks/m4-air.md" ;;
    *m1-pro*|*macbook-pro*)   TASK_FILE="tasks/m1-pro.md" ;;
  esac

  # 미완료 태스크 수집
  PENDING=""
  if [ -n "$TASK_FILE" ] && [ -f "$ORCH_REPO/$TASK_FILE" ]; then
    PENDING=$(grep '^\- \[ \]' "$ORCH_REPO/$TASK_FILE" 2>/dev/null)
  fi

  # 최신 핸드오프 찾기
  LATEST_HANDOFF=$(ls -t "$ORCH_REPO"/handoffs/*.md 2>/dev/null | head -1)
  HANDOFF_SUMMARY=""
  if [ -n "$LATEST_HANDOFF" ]; then
    # 핸드오프 파일의 첫 20줄 + "다음 세션에서 이어서 할 것" 섹션
    HANDOFF_SUMMARY=$(awk '/^## 다음 세션/{found=1} found{print}' "$LATEST_HANDOFF" 2>/dev/null)
    if [ -z "$HANDOFF_SUMMARY" ]; then
      HANDOFF_SUMMARY=$(head -20 "$LATEST_HANDOFF" 2>/dev/null)
    fi
  fi

  # additionalContext로 출력
  if [ -n "$PENDING" ] || [ -n "$HANDOFF_SUMMARY" ]; then
    echo ""
    echo "━━━ 🖥 Homelab Handoff ($MACHINE) ━━━"
    if [ -n "$PENDING" ]; then
      TODO_COUNT=$(echo "$PENDING" | wc -l | tr -d ' ')
      echo ""
      echo "📋 이 머신 미완료 태스크 (${TODO_COUNT}개):"
      echo "$PENDING"
    fi
    if [ -n "$HANDOFF_SUMMARY" ]; then
      HO_NAME=$(basename "$LATEST_HANDOFF" .md)
      echo ""
      echo "📨 최신 핸드오프: $HO_NAME"
      echo "$HANDOFF_SUMMARY"
    fi
    echo ""
    echo "📁 전체 태스크: $ORCH_REPO/$TASK_FILE"
    echo "📁 전체 핸드오프: $LATEST_HANDOFF"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  fi

  cd - > /dev/null 2>&1
fi

exit 0
