# Dev Where - 어디서 작업 중이었지?

$ARGUMENTS

## Instructions

3대 머신의 최신 상태를 한눈에 보여줍니다.
"어디서 뭘 하고 있었지?" 에 대한 즉각적인 답을 제공합니다.

### 1. 머신 데이터 동기화

먼저 dev-retrospective repo를 최신화하여 다른 머신들의 데이터를 받아옵니다:

```bash
cd "$HOME/projects/dev-retrospective" && git pull --rebase 2>/dev/null
```

### 2. 모든 머신 상태 로드

```bash
MACHINES_DIR="$HOME/.dev-retrospective/data/machines"
for mdir in "$MACHINES_DIR"/*/; do
  mname=$(basename "$mdir")
  mfile="$mdir/last_session.json"
  [ -f "$mfile" ] && cat "$mfile"
done
```

### 3. 현재 머신의 프로젝트 상태

```bash
CURRENT_MACHINE=$(hostname -s)
PROJECTS_DIR="$HOME/projects"
for dir in "$PROJECTS_DIR"/*/; do
  if [ -d "$dir/.git" ]; then
    cd "$dir"
    name=$(basename "$dir")
    branch=$(git branch --show-current 2>/dev/null)
    changes=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    unpushed=$(git log @{u}..HEAD --oneline 2>/dev/null | wc -l | tr -d ' ')
    if [ "$changes" -gt 0 ] || [ "$unpushed" -gt 0 ]; then
      echo "$name|$branch|changes=$changes|unpushed=$unpushed"
    fi
  fi
done
```

### 4. 분석 및 출력

모든 머신의 last_session.json 데이터를 **timestamp 기준 정렬**하여 가장 최근 작업한 머신을 맨 위에 표시합니다.

## Output

```
## 🔍 어디서 작업 중이었지?

### 마지막 작업
- **머신**: {가장 최근 timestamp의 머신}
- **프로젝트**: {project}
- **브랜치**: {branch}
- **시간**: {timestamp를 한국시간으로 변환} ({N시간 전})

### 전체 머신 현황
| 머신 | 마지막 작업 | 프로젝트 | 브랜치 | 미push | dirty | 경과 |
|------|------------|----------|--------|--------|-------|------|
| {각 머신의 데이터를 timestamp 역순으로 정렬} |

### 이 머신({hostname})의 미정리 작업
| 프로젝트 | 브랜치 | 변경 파일 | 미push 커밋 |
|----------|--------|----------|------------|
(dirty 또는 unpushed 있는 프로젝트만 표시. 없으면 "✅ 깨끗합니다")

### 💡 추천
{상황에 맞는 추천:
- "M4 Studio에서 thinkingos 작업을 이어서 하세요 (git pull 먼저)"
- "이 머신에 push 안 된 커밋이 있습니다. 먼저 push 하세요"
- "모든 머신 깨끗합니다. 새 작업을 시작하세요"
등}
```
