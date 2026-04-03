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
    # Save full transcript (needed for AI auto-log)
    cp "$transcript_path" "$BACKUP_DIR/session_${timestamp}_${reason}.jsonl" 2>/dev/null
    FULL_TRANSCRIPT="$BACKUP_DIR/session_${timestamp}_${reason}.jsonl"
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

# Dynamic vault detection
# Windows: Claude Code runs .sh hooks via Git Bash.
# Known issue: If WSL is installed, bash may resolve to WSL bash.
# Fix: Set CLAUDE_CODE_GIT_BASH_PATH in settings.json
# See: https://github.com/anthropics/claude-code/issues/23556
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." 2>/dev/null && pwd)"
if [[ -f "$SCRIPT_DIR/scripts/vault-detect.sh" ]]; then
  source "$SCRIPT_DIR/scripts/vault-detect.sh"
elif [[ -f "$HOME/.dev-retrospective/scripts/vault-detect.sh" ]]; then
  source "$HOME/.dev-retrospective/scripts/vault-detect.sh"
else
  VAULT_BASE=""
fi
if [[ -z "${VAULT_BASE:-}" ]]; then
  VAULT_BASE=$(find_vault 2>/dev/null || echo "")
fi
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

# === AI Auto-Log (background) ===
# skeleton은 즉시 생성되고, auto-log가 성공하면 skeleton을 대체
AUTO_LOG_SCRIPT="$HOME/.claude/hooks/session-auto-log.sh"
# API 키: 현재 환경에 없으면 .zshenv/.zshrc에서 로드 시도
if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
  [ -f "$HOME/.zshenv" ] && source "$HOME/.zshenv" 2>/dev/null
  [ -f "$HOME/.zshrc" ] && grep -q "ANTHROPIC_API_KEY" "$HOME/.zshrc" 2>/dev/null && \
    eval "$(grep 'export ANTHROPIC_API_KEY' "$HOME/.zshrc" | head -1)"
fi
if [ -x "$AUTO_LOG_SCRIPT" ] && [ -n "${FULL_TRANSCRIPT:-}" ] && [ -n "${ANTHROPIC_API_KEY:-}" ]; then
  ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" \
    nohup bash "$AUTO_LOG_SCRIPT" "$FULL_TRANSCRIPT" "$reason" "$CURRENT_DIR" \
    >> "$BACKUP_DIR/auto-log.log" 2>&1 &
fi

# === unpushed work 경고 ===
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  BRANCH=$(git branch --show-current 2>/dev/null)

  # 1. 커밋되지 않은 변경사항
  DIRTY=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')

  # 2. push 안 된 커밋 수
  UNPUSHED=$(git log @{u}.. --oneline 2>/dev/null | wc -l | tr -d ' ')

  # 3. upstream 없는 브랜치 (로컬만 존재)
  HAS_UPSTREAM=$(git rev-parse --abbrev-ref @{u} 2>/dev/null)

  if [ "$DIRTY" -gt 0 ] || [ "$UNPUSHED" -gt 0 ] || [ -z "$HAS_UPSTREAM" ]; then
    echo ""
    echo "⚠️  [dev-retrospective] 이 머신에 남은 작업:"
    [ "$DIRTY" -gt 0 ] && echo "   - 커밋되지 않은 변경: ${DIRTY}개 파일"
    [ "$UNPUSHED" -gt 0 ] && echo "   - push 안 된 커밋: ${UNPUSHED}개 (branch: $BRANCH)"
    [ -z "$HAS_UPSTREAM" ] && echo "   - 로컬 전용 브랜치: $BRANCH (upstream 없음)"
    echo ""
  fi
fi

# === 머신별 상태를 repo에도 저장 (멀티머신 공유) ===
MACHINE_DIR="$HOME/.dev-retrospective/data/machines/$MACHINE"
mkdir -p "$MACHINE_DIR"

cat > "$MACHINE_DIR/last_session.json" << EOMACHINE
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "machine": "$MACHINE",
  "reason": "$reason",
  "cwd": "$(pwd)",
  "project": "$(basename "$(pwd)")",
  "git_branch": "$(git branch --show-current 2>/dev/null || echo "none")",
  "unpushed_commits": ${UNPUSHED:-0},
  "dirty_files": ${DIRTY:-0},
  "has_upstream": $([ -n "$HAS_UPSTREAM" ] && echo "true" || echo "false")
}
EOMACHINE

# === Homelab: handoff → task 자동 변환 ===
ORCH_REPO="$HOME/projects/homelab-orchestration"
TASK_SYNC="$ORCH_REPO/bin/task-sync.sh"
if [ -x "$TASK_SYNC" ]; then
  bash "$TASK_SYNC" 2>/dev/null || true
fi

# === Homelab Orchestration 태스크 자동 동기화 ===
if [ -d "$ORCH_REPO/.git" ]; then
  cd "$ORCH_REPO"

  # tasks/ 또는 handoffs/ 에 변경사항이 있으면 자동 commit+push
  TASK_CHANGES=$(git status --porcelain tasks/ handoffs/ 2>/dev/null | wc -l | tr -d ' ')

  if [ "$TASK_CHANGES" -gt 0 ]; then
    MACHINE=$(hostname -s | tr '[:upper:]' '[:lower:]')
    git add tasks/ handoffs/ 2>/dev/null
    git commit -m "auto-sync: ${MACHINE} 세션 종료 시 태스크/핸드오프 동기화" --quiet 2>/dev/null
    git push origin main --quiet 2>/dev/null
  fi

  cd - > /dev/null 2>&1
fi

exit 0
