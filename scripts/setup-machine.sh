#!/bin/bash
# setup-machine.sh — dev-retrospective 환경 자동 설치
# 어떤 맥에서든 한 번 실행하면 체크인/체크아웃/회고 시스템이 셋업됩니다.
#
# Usage:
#   curl -s ... | bash   (or)
#   bash setup-machine.sh

set -euo pipefail

MACHINE=$(hostname -s)
REPO_URL="git@github.com:nori00000/dev-retrospective.git"
PROJECTS_DIR="$HOME/projects"
RETRO_DIR="$PROJECTS_DIR/dev-retrospective"
LINK_TARGET="$HOME/.dev-retrospective"
CLAUDE_DIR="$HOME/.claude"
COMMANDS_DIR="$CLAUDE_DIR/commands"
SKILLS_DIR="$CLAUDE_DIR/skills/omc-learned"
MACHINES_DATA_DIR="$RETRO_DIR/data/machines/$MACHINE"
LOG_DIR="$CLAUDE_DIR/logs"

echo "🔧 dev-retrospective 환경 설치 시작 (머신: $MACHINE)"
echo ""

# 1. Clone or pull repo
echo "📦 1/7 — 리포지토리 준비"
mkdir -p "$PROJECTS_DIR"
if [ -d "$RETRO_DIR/.git" ]; then
  echo "  이미 존재. git pull..."
  cd "$RETRO_DIR" && git pull --rebase
else
  echo "  클론 중..."
  git clone "$REPO_URL" "$RETRO_DIR"
fi

# 2. Create symlink ~/.dev-retrospective -> ~/projects/dev-retrospective
echo "🔗 2/7 — 심볼릭 링크 설정"
if [ -L "$LINK_TARGET" ]; then
  echo "  이미 존재: $(readlink $LINK_TARGET)"
elif [ -d "$LINK_TARGET" ]; then
  echo "  ⚠️ 디렉토리가 이미 존재합니다. 수동 확인 필요: $LINK_TARGET"
else
  ln -s "$RETRO_DIR" "$LINK_TARGET"
  echo "  생성: $LINK_TARGET -> $RETRO_DIR"
fi

# 3. Link commands to ~/.claude/commands/
echo "📋 3/7 — Claude 명령어 링크"
mkdir -p "$COMMANDS_DIR"
for cmd in dev-checkin dev-daily dev-weekly dev-monthly dev-consult dev-radar dev-inbox dev-setup session-log; do
  src="$LINK_TARGET/commands/${cmd}.md"
  dst="$COMMANDS_DIR/${cmd}.md"
  if [ -f "$src" ]; then
    if [ -L "$dst" ]; then
      echo "  이미 링크됨: $cmd"
    else
      ln -sf "$src" "$dst"
      echo "  링크 생성: $cmd"
    fi
  else
    echo "  ⚠️ 소스 없음: $src"
  fi
done

# 4. Install skills (auto-checkin, auto-checkout, auto-retrospective)
echo "🎯 4/7 — 스킬 설치"
mkdir -p "$SKILLS_DIR"
for skill in auto-checkin auto-checkout auto-retrospective; do
  src_dir="$RETRO_DIR/skills/${skill}"
  dst_dir="$SKILLS_DIR/${skill}"
  if [ -d "$src_dir" ]; then
    mkdir -p "$dst_dir"
    cp "$src_dir/SKILL.md" "$dst_dir/SKILL.md" 2>/dev/null && echo "  설치: $skill" || echo "  ⚠️ SKILL.md 없음: $skill"
  fi
done

# 5. Initialize machine data
echo "🖥️  5/7 — 머신 데이터 초기화 ($MACHINE)"
mkdir -p "$MACHINES_DATA_DIR"
if [ ! -f "$MACHINES_DATA_DIR/last_session.json" ]; then
  cat > "$MACHINES_DATA_DIR/last_session.json" << ENDJSON
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "machine": "$MACHINE",
  "reason": "setup",
  "cwd": "$HOME",
  "project": "none",
  "git_branch": "none",
  "unpushed_commits": 0,
  "dirty_files": 0,
  "has_upstream": false
}
ENDJSON
  echo "  생성: last_session.json"
else
  echo "  이미 존재"
fi

# 6. Create log directory
echo "📁 6/7 — 로그 디렉토리"
mkdir -p "$LOG_DIR"
echo "  확인: $LOG_DIR"

# 7. Register cron jobs (only on always-on machines like m4-studio)
echo "⏰ 7/7 — 크론 작업"
CRON_SCRIPT="$RETRO_DIR/scripts/dev-review-cron.sh"
chmod +x "$CRON_SCRIPT" 2>/dev/null

# Check if cron entries already exist
if crontab -l 2>/dev/null | grep -q "dev-review-cron"; then
  echo "  이미 등록됨"
else
  echo "  크론 등록 중..."
  (crontab -l 2>/dev/null; cat <<CRON
# === dev-review 자동 회고 ===
# Daily 회고 (매일 22:00)
0 22 * * * $CRON_SCRIPT daily >> $LOG_DIR/dev-review-daily.log 2>&1
# Weekly 회고 (매주 일요일 21:00)
0 21 * * 0 $CRON_SCRIPT weekly >> $LOG_DIR/dev-review-weekly.log 2>&1
CRON
  ) | crontab -
  echo "  등록 완료"
fi

echo ""
echo "✅ 설치 완료!"
echo ""
echo "사용법:"
echo "  체크인: Claude Code에서 '체크인' 또는 '출근' 입력"
echo "  체크아웃: '체크아웃' 또는 '퇴근' 입력"
echo "  회고: '회고' 또는 '작업 끝' 입력"
echo ""
echo "머신 상태가 GitHub을 통해 다른 머신과 공유됩니다."
