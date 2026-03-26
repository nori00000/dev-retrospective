#!/bin/bash
# cmds-post-validate.sh - PostToolUse: Write/Edit 후 CMDS 규칙 자동 검증
# 위반 시 Claude에게 피드백하여 자동 수정 유도

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# file_path가 없으면 무시
[[ -z "$FILE_PATH" ]] && exit 0

# .md 파일이 아니면 무시
[[ "$FILE_PATH" != *.md ]] && exit 0

# Claude 설정 파일 제외
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

# Vault 밖이면 무시
[[ "$FILE_PATH" != "$VAULT"* ]] && exit 0

# 파일 존재 확인
[[ ! -f "$FILE_PATH" ]] && exit 0

BASENAME=$(basename "$FILE_PATH")

# 시스템/설정 파일 제외
case "$FILE_PATH" in
  *"CLAUDE.md"|*"AGENTS.md"|*"CMDS.md") exit 0 ;;
  *"90. Settings/"*|*"91. Templates/"*|*".obsidian/"*) exit 0 ;;
esac

ERRORS=()
WARNINGS=()

# --- 검증 1: YAML frontmatter 존재 ---
FIRST_LINE=$(head -1 "$FILE_PATH")
if [[ "$FIRST_LINE" != "---" ]]; then
  ERRORS+=("YAML frontmatter 없음. 파일 첫 줄이 ---로 시작해야 합니다")
else
  # YAML 영역 추출
  YAML_CONTENT=$(awk '/^---$/{c++;if(c==2)exit}c==1' "$FILE_PATH")

  # 닫는 --- 확인
  CLOSING=$(awk '/^---$/{c++}c==2{print "found";exit}' "$FILE_PATH")
  if [[ "$CLOSING" != "found" ]]; then
    ERRORS+=("YAML frontmatter 닫는 --- 누락")
  fi

  # --- 검증 2: 필수 Properties ---
  for prop in "type:" "aliases:" "author:" "date created:" "date modified:" "tags:"; do
    if ! printf '%s' "$YAML_CONTENT" | grep -q "^${prop}"; then
      ERRORS+=("필수 Property 누락: ${prop}")
    fi
  done

  # --- 검증 3: YAML 탭 사용 금지 ---
  TAB=$(printf '\t')
  if printf '%s' "$YAML_CONTENT" | grep -q "$TAB"; then
    ERRORS+=("YAML에서 탭 사용 감지. 2 SPACES로 들여쓰기 필요")
  fi

  # --- 검증 4: Wikilinks 따옴표 ---
  # 배열 항목에서 따옴표 없는 wikilink: "  - [[..." 패턴
  if printf '%s\n' "$YAML_CONTENT" | grep -qE '^[[:space:]]+-[[:space:]]+\[\['; then
    ERRORS+=("YAML 배열 내 wikilink 따옴표 누락. - \"[[링크]]\" 형식 필요")
  fi
  # 키-값에서 따옴표 없는 wikilink: "key: [[..." 패턴
  if printf '%s\n' "$YAML_CONTENT" | grep -qE '^[a-zA-Z][a-zA-Z ]*:[[:space:]]+\[\['; then
    ERRORS+=("YAML 값에서 wikilink 따옴표 누락. 예: CMDS: \"[[📚 620 Generative AI]]\"")
  fi

  # --- 검증 5: date created 형식 ---
  DC=$(printf '%s\n' "$YAML_CONTENT" | grep "^date created:" | sed 's/^date created:[[:space:]]*//')
  if [[ -n "$DC" ]] && ! printf '%s' "$DC" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}'; then
    ERRORS+=("date created 형식 오류: '$DC' → YYYY-MM-DD 필요")
  fi

  # --- 검증 6: date modified 형식 ---
  DM=$(printf '%s\n' "$YAML_CONTENT" | grep "^date modified:" | sed 's/^date modified:[[:space:]]*//')
  if [[ -n "$DM" ]] && ! printf '%s' "$DM" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}'; then
    ERRORS+=("date modified 형식 오류: '$DM' → YYYY-MM-DD 필요")
  fi

  # --- 검증 7: type 유효성 ---
  TYPE_VAL=$(printf '%s\n' "$YAML_CONTENT" | grep "^type:" | sed 's/^type:[[:space:]]*//')
  VALID_TYPES="note|terminology|meeting|people|curriculum|memo|class|manuscript|daily-note|article|sermon|review|project|zettel|CMDS|organization|portal|documentation|index|moc|books|research-review|idea|resource|product|session-log"
  if [[ -n "$TYPE_VAL" ]] && ! printf '%s' "$TYPE_VAL" | grep -qE "^($VALID_TYPES)$"; then
    WARNINGS+=("type '$TYPE_VAL' 비표준. 표준: note, meeting, terminology, people, article, project 등")
  fi

  # --- 검증 8: author에 이상민 포함 ---
  if printf '%s\n' "$YAML_CONTENT" | grep -q "^author:" && ! printf '%s\n' "$YAML_CONTENT" | grep -q '이상민'; then
    WARNINGS+=("author에 [[이상민]]이 없습니다")
  fi

  # --- 검증 9: tags 최소 3개 필수, 빈 태그 금지 ---
  if printf '%s\n' "$YAML_CONTENT" | grep -q "^tags:"; then
    TAGS_LINE=$(printf '%s\n' "$YAML_CONTENT" | grep "^tags:" | sed 's/^tags:[[:space:]]*//')

    # 인라인 배열: tags: [] 또는 tags: [a, b]
    if printf '%s' "$TAGS_LINE" | grep -qE '^\['; then
      # 빈 배열 체크
      if printf '%s' "$TAGS_LINE" | grep -qE '^\[\s*\]$'; then
        ERRORS+=("tags가 비어 있음. 최소 3개 태그 필요 (예: tags: [branding, consulting, AI])")
      else
        # 쉼표로 개수 세기 (항목 = 쉼표 수 + 1)
        TAG_COUNT=$(printf '%s' "$TAGS_LINE" | tr -cd ',' | wc -c | tr -d ' ')
        TAG_COUNT=$((TAG_COUNT + 1))
        if [[ $TAG_COUNT -lt 3 ]]; then
          ERRORS+=("tags가 ${TAG_COUNT}개뿐. 최소 3개 필요")
        fi
      fi
    else
      # 멀티라인 배열: tags:\n  - tag1\n  - tag2
      TAG_COUNT=$(printf '%s\n' "$YAML_CONTENT" | awk '/^tags:/{found=1;next} found && /^[[:space:]]+-/{count++} found && /^[a-zA-Z]/{exit} END{print count+0}')
      if [[ $TAG_COUNT -eq 0 ]]; then
        ERRORS+=("tags가 비어 있음. 최소 3개 태그 필요")
      elif [[ $TAG_COUNT -lt 3 ]]; then
        ERRORS+=("tags가 ${TAG_COUNT}개뿐. 최소 3개 필요")
      fi
    fi
  fi
fi

# --- 결과 출력 ---
if [[ ${#ERRORS[@]} -eq 0 && ${#WARNINGS[@]} -eq 0 ]]; then
  echo "[CMDS] ✅ 검증 통과: $BASENAME"
  exit 0
fi

echo "[CMDS] 검증 결과 [$BASENAME]:"

for err in "${ERRORS[@]}"; do
  echo "  ❌ $err"
done

for warn in "${WARNINGS[@]}"; do
  echo "  ⚠️ $warn"
done

if [[ ${#ERRORS[@]} -gt 0 ]]; then
  echo "  → 위 ❌ 오류를 즉시 수정하세요."
fi

exit 0
