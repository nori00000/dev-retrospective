#!/bin/bash
# Session End Hook - Automatically backup session state

# Read hook input from stdin
read -r hook_input

# Extract session info
reason=$(echo "$hook_input" | jq -r '.reason // "unknown"')
transcript_path=$(echo "$hook_input" | jq -r '.transcript_path // ""')

# Backup directory
BACKUP_DIR="$HOME/.claude/session-backups"
mkdir -p "$BACKUP_DIR"

# Timestamp
timestamp=$(date +%Y%m%d_%H%M%S)

# Backup transcript if available
if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
    # Get last 100 lines as summary (recent conversation)
    tail -100 "$transcript_path" > "$BACKUP_DIR/session_${timestamp}_${reason}.jsonl" 2>/dev/null
fi

# Save current working directory info
echo "{
  \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",
  \"reason\": \"$reason\",
  \"cwd\": \"$(pwd)\",
  \"git_branch\": \"$(git branch --show-current 2>/dev/null || echo 'none')\",
  \"transcript_backup\": \"session_${timestamp}_${reason}.jsonl\"
}" > "$BACKUP_DIR/last_session.json"

# --- Obsidian Session Skeleton ---
# 안전망: AI 분석 로그가 없을 때 스켈레톤 노트 자동 생성

VAULT_BASE="$HOME/Documents/Obsidian-0.1"
SESSIONS_DIR="$VAULT_BASE/00. Inbox/03. AI Agent/sessions"
MACHINE=$(hostname -s)
DATE_STAMP=$(date +%Y-%m-%d)
TIME_HHMM=$(date +%H%M)
FULL_DATETIME=$(date +"%Y-%m-%d %H:%M")
GIT_BRANCH=$(git branch --show-current 2>/dev/null || echo "none")
PROJECT=$(basename "$(pwd)")
CURRENT_DIR=$(pwd)

# 세션 디렉토리 생성
mkdir -p "$SESSIONS_DIR"

# 오늘 날짜+시간 prefix로 이미 AI 생성 로그가 있는지 확인
EXISTING=$(find "$SESSIONS_DIR" -name "${DATE_STAMP}-${TIME_HHMM}-*" -type f 2>/dev/null | head -1)

# 같은 분에 생성된 AI 로그가 없으면 스켈레톤 생성
if [ -z "$EXISTING" ]; then
  SKELETON_FILE="$SESSIONS_DIR/${DATE_STAMP}-${TIME_HHMM}-session-skeleton.md"

  cat > "$SKELETON_FILE" << HEREDOC
---
type: session-log
aliases:
  - "Session ${DATE_STAMP} ${TIME_HHMM}"
author:
  - "[[이상민]]"
date created: ${DATE_STAMP}
date modified: ${DATE_STAMP}
tags:
  - session-log
  - skeleton
CMDS: "[[📚 907 Technology & Development Division]]"
index: "[[🏷 Session Logs]]"
status: inProgress
machine: ${MACHINE}
agent: claude-code
project: ${PROJECT}
git_branch: ${GIT_BRANCH}
---

# Session ${DATE_STAMP} ${TIME_HHMM}

> **세션 정보**
> - 날짜: ${FULL_DATETIME}
> - 머신: ${MACHINE}
> - 에이전트: Claude Code
> - 프로젝트: ${PROJECT} (\`${CURRENT_DIR}\`)
> - 브랜치: ${GIT_BRANCH}
> - 종료 사유: ${reason}

---

> [!warning] 스켈레톤 노트
> 이 노트는 SessionEnd hook에 의해 자동 생성되었습니다.
> \`/session-log\` 명령으로 AI 분석된 상세 로그를 생성하세요.

## 작업 요약

(AI 분석 대기중)

## 미완료 / 후속 작업

- [ ] \`/session-log\` 명령으로 상세 로그 생성
HEREDOC
fi

exit 0
