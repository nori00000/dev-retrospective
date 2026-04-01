# Dev Check-in - 세션 시작 체크인

$ARGUMENTS

## Instructions

새 개발 세션을 시작할 때 실행합니다.
과거 회고에서 축적된 지식을 불러와 이번 세션에 반영합니다.

### 1. 현재 프로젝트 파악

```bash
PROJECT=$(basename "$(pwd)")
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
GIT_BRANCH=$(git branch --show-current 2>/dev/null || echo "none")
```

### 1.5 현재 프로젝트 자동 동기화

현재 프로젝트가 git 프로젝트이고 remote가 있으면 자동으로 pull합니다:

```bash
if [ -n "$GIT_ROOT" ]; then
  HAS_REMOTE=$(git remote 2>/dev/null | head -1)
  if [ -n "$HAS_REMOTE" ]; then
    DIRTY=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    if [ "$DIRTY" -gt 0 ]; then
      echo "📦 로컬 변경사항 임시 저장 (git stash)..."
      git stash push -m "auto-stash-checkin-$(date +%Y%m%d-%H%M%S)" 2>&1
      STASHED=true
    else
      STASHED=false
    fi
    echo "📥 git pull --rebase 실행 중..."
    git pull --rebase 2>&1 || echo "⚠️ pull 실패 - 수동 확인 필요"
    if [ "$STASHED" = true ]; then
      echo "📦 임시 저장한 변경사항 복원 중..."
      git stash pop 2>&1 || echo "⚠️ stash pop 충돌 - 수동으로 'git stash pop' 후 충돌 해결 필요"
    fi
  else
    echo "⚠️ remote 없음 - GitHub에 연결되지 않은 프로젝트입니다"
  fi
fi
```

### 2. 최근 세션 히스토리 로드

#### 2.1 이 프로젝트의 최근 세션 로그 (최대 5개)

```bash
SESSIONS_DIR="$HOME/Documents/Obsidian-0.1/00. Inbox/03. AI Agent/sessions"
grep -l "project: $PROJECT" "$SESSIONS_DIR"/*.md 2>/dev/null | sort -r | head -5
```

#### 2.2 최근 일간 회고 (최대 3개)

```bash
DAILY_DIR="$HOME/Documents/Obsidian-0.1/00. Inbox/03. AI Agent/sessions/reviews/daily"
ls "$DAILY_DIR"/*.md 2>/dev/null | sort -r | head -3
```

#### 2.3 가장 최근 주간 회고

```bash
WEEKLY_DIR="$HOME/Documents/Obsidian-0.1/00. Inbox/03. AI Agent/sessions/reviews/weekly"
ls "$WEEKLY_DIR"/*.md 2>/dev/null | sort -r | head -1
```

#### 2.4 최근 개발 생산성 상의 결과

```bash
CONSULT_DIR="$HOME/Documents/Obsidian-0.1/00. Inbox/03. AI Agent/sessions/reviews/consult"
ls "$CONSULT_DIR"/*.md 2>/dev/null | sort -r | head -1
```

합의된 개선 사항과 실행 항목 추출.

#### 2.5 멀티머신 현황 로드

```bash
MACHINES_DIR="$HOME/.dev-retrospective/data/machines"
CURRENT_MACHINE=$(hostname -s)
for mdir in "$MACHINES_DIR"/*/; do
  mname=$(basename "$mdir")
  mfile="$mdir/last_session.json"
  [ -f "$mfile" ] && cat "$mfile"
done
```

각 머신의 last_session.json을 읽어 다음을 표시:
- 머신 이름, 마지막 작업 프로젝트, 시간
- unpushed 커밋/dirty 파일 수
- upstream 없는 브랜치 경고

#### 2.6 Tech Radar & Inbox 미검토 항목

```bash
RADAR_DIR="$HOME/Documents/Obsidian-0.1/00. Inbox/03. AI Agent/sessions/reviews/radar"
INBOX_FILE="$HOME/Documents/Obsidian-0.1/00. Inbox/03. AI Agent/sessions/reviews/inbox/dev-inbox.md"
ls "$RADAR_DIR"/*.md 2>/dev/null | sort -r | head -1
cat "$INBOX_FILE" 2>/dev/null | grep "🆕 미검토" | head -5
```

Adopt/Trial 결정 항목과 미검토 inbox 항목 추출.

#### 2.7 전체 프로젝트 상태 스캔

```bash
PROJECTS_DIR="$HOME/projects"
for dir in "$PROJECTS_DIR"/*/; do
  if [ -d "$dir/.git" ]; then
    cd "$dir"
    name=$(basename "$dir")
    changes=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    has_remote=$(git remote 2>/dev/null | head -1)
    unpushed=$(git log @{u}..HEAD --oneline 2>/dev/null | wc -l | tr -d ' ')
    if [ "$changes" -gt 0 ] || [ "$unpushed" -gt 0 ] || [ -z "$has_remote" ]; then
      echo "$name: changes=$changes unpushed=$unpushed remote=${has_remote:-NONE}"
    fi
  fi
done
```

각 프로젝트의 다음 상태를 표시:
- dirty 파일이 있는 프로젝트
- push 안 된 커밋이 있는 프로젝트
- remote가 설정되지 않은 프로젝트 (⚠️ 경고)

### 3. 미완료 작업 집계

모든 세션 로그와 일간 회고에서 `- [ ]` 패턴의 미완료 TODO를 수집합니다.

### 4. 주의사항 추출

과거 회고에서 "실수", "주의", "삽질" 등 키워드가 포함된 TIL을 추출합니다.

### 5. 프로젝트 CLAUDE.md 교훈 확인

```bash
if [ -f "$GIT_ROOT/CLAUDE.md" ]; then cat "$GIT_ROOT/CLAUDE.md"; fi
if [ -f "$GIT_ROOT/.claude/CLAUDE.md" ]; then cat "$GIT_ROOT/.claude/CLAUDE.md"; fi
```

## Output

```
## Dev Check-in: {PROJECT}

### 현재 상태
- **프로젝트**: {project}
- **브랜치**: {branch}
- **마지막 세션**: {날짜} - {제목}

### 머신 현황
| 머신 | 마지막 작업 | 프로젝트 | 브랜치 | 미push | 경고 |
|------|------------|----------|--------|--------|------|
(각 머신의 last_session.json 데이터로 테이블 생성)

### ⚠️ 주의 필요 프로젝트
| 프로젝트 | 문제 | 상세 |
|----------|------|------|
(전체 프로젝트 스캔에서 이상 있는 항목만 표시. remote 없음, 미push 커밋, dirty 파일 등)
없으면 "✅ 모든 프로젝트 정상" 표시

### 동기화 결과
- `git pull --rebase`: {성공/실패/해당없음}

### 미완료 백로그 ({N}개)
1. {TODO1}
2. {TODO2}

### 주의사항 (과거 회고에서)
- {주의1}

### 활용할 교훈
- {교훈1}

### 합의된 개선 사항 (최근 /dev-consult에서)
- {개선1}

### Tech Inbox 미검토 ({N}개)
- {항목1}

### 제안: 이번 세션 목표
1. {목표1}
```
