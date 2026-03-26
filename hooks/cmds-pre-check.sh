#!/bin/bash
# cmds-pre-check.sh - PreToolUse: Write/Edit 전 CMDS 규칙 리마인더
# Vault 내 .md 파일에만 핵심 규칙을 간결하게 상기시킴

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# file_path가 없으면 (Edit의 경우 등) 무시
[[ -z "$FILE_PATH" ]] && exit 0

# .md 파일이 아니면 무시
[[ "$FILE_PATH" != *.md ]] && exit 0

# Claude 설정 파일 제외 (.claude/ 하위)
[[ "$FILE_PATH" == *"/.claude/"* ]] && exit 0

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
  exit 0
fi
VAULT=$(find_vault 2>/dev/null || echo "")
[[ -z "$VAULT" ]] && exit 0

# Vault 밖 .md → 경고
if [[ "$FILE_PATH" != "$VAULT"* ]]; then
  echo "[CMDS] Vault 밖에 .md 생성 감지. 올바른 위치: $VAULT/00. Inbox/03. AI Agent/"
  exit 0
fi

# 시스템/설정 파일 제외
case "$FILE_PATH" in
  *"CLAUDE.md"|*"AGENTS.md"|*"CMDS.md") exit 0 ;;
  *"90. Settings/"*|*".obsidian/"*) exit 0 ;;
esac

# 간결한 리마인더 (핵심만)
cat << 'EOF'
[CMDS] .md 파일 작성 규칙:
- YAML frontmatter 필수 (---로 시작/끝)
- 필수 Properties: type, aliases, author, date created, date modified, tags
- author: - "[[이상민]]" (quoted wikilink)
- tags: 최소 3개 필수 (빈 배열 금지). 문서 내용에 맞는 관련 태그 작성
- YAML: 2 spaces / Markdown 본문: TAB
- 날짜: YYYY-MM-DD
EOF

exit 0
