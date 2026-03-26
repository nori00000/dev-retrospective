#!/bin/bash
# sync-and-enrich.sh - 로컬 AI 보강 스크립트
# GH Actions가 생성한 raw stats를 Claude CLI로 분석

set -euo pipefail
export PATH="/usr/local/bin:$HOME/.npm-global/bin:$PATH"

REPO_ROOT="$HOME/.dev-retrospective"
LOG_DIR="$HOME/.claude/logs"
mkdir -p "$LOG_DIR"

echo "[$(date)] Starting sync-and-enrich..."

# 1. Pull latest
cd "$REPO_ROOT"
git pull --ff-only 2>/dev/null || {
  echo "[WARN] git pull failed, trying merge..."
  git pull --no-rebase 2>/dev/null || {
    echo "[ERROR] git pull failed"
    exit 1
  }
}

# 2. Find raw stats without corresponding review
ENRICHED=0
for RAW_FILE in data/reviews/*/*-stats-raw.md; do
  [ -f "$RAW_FILE" ] || continue
  REVIEW_FILE="${RAW_FILE%-stats-raw.md}-review.md"

  if [ -f "$REVIEW_FILE" ]; then
    continue  # Already enriched
  fi

  echo "[ENRICH] Processing: $RAW_FILE"

  # Extract mode from frontmatter
  MODE=$(grep "^mode:" "$RAW_FILE" | awk '{print $2}' || echo "daily")

  # Claude CLI available?
  CLAUDE_CMD=$(which claude 2>/dev/null || echo "/usr/local/bin/claude")
  if [ ! -x "$CLAUDE_CMD" ]; then
    echo "[SKIP] Claude CLI not found, skipping AI enrichment"
    continue
  fi

  # Generate AI review
  PROMPT="다음은 GitHub 리포 통계 데이터입니다. 한국어로 개발 회고 리뷰를 작성해주세요.

주요 분석 포인트:
- 커밋 빈도와 패턴
- PR/이슈 활동
- 주요 변경사항 요약
- 개선 제안

$(cat "$RAW_FILE")"

  $CLAUDE_CMD -p "$PROMPT" > "$REVIEW_FILE" 2>/dev/null || {
    echo "[ERROR] Claude CLI failed for $RAW_FILE"
    continue
  }

  ENRICHED=$((ENRICHED + 1))
  echo "[OK] Review generated: $REVIEW_FILE"
done

# 3. Commit and push if there are new reviews
if [ $ENRICHED -gt 0 ]; then
  cd "$REPO_ROOT"
  git add data/reviews/
  git diff --cached --quiet || {
    git commit -m "review: AI enrichment ($ENRICHED files) from $(hostname -s)"
    git push
    echo "[OK] Pushed $ENRICHED review files"
  }
else
  echo "[OK] No new stats to enrich"
fi

echo "[$(date)] sync-and-enrich complete. Enriched: $ENRICHED"
