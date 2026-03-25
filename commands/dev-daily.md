# Daily Development Review - 일간 개발 회고

$ARGUMENTS

## Instructions

오늘 하루의 개발 작업을 집계하여 **일간 개발 회고**를 생성합니다.
두 가지 출력: Obsidian 상세 노트 + GitHub devlog 간결 버전.

### 1. 데이터 수집

#### 1.1 오늘의 세션 로그 수집

```bash
TODAY=$(date +%Y-%m-%d)
SESSIONS_DIR="$HOME/Documents/Obsidian-0.1/00. Inbox/03. AI Agent/sessions"
ls "$SESSIONS_DIR"/${TODAY}-* 2>/dev/null
```

각 세션 로그 파일을 읽어서:
- 작업 요약 추출
- 핵심 결정 추출
- 배운 점(TIL) 추출
- 미완료 작업 추출
- review_tags 집계
- session_metrics 합산

#### 1.2 오늘의 Git 히스토리 수집

```bash
git log --oneline --since="$(date +%Y-%m-%d)" 2>/dev/null
git log --stat --since="$(date +%Y-%m-%d)" 2>/dev/null | tail -5
```

#### 1.3 프로젝트 정보

```bash
PROJECT=$(basename "$(pwd)")
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
GIT_BRANCH=$(git branch --show-current 2>/dev/null || echo "none")
```

### 2. Obsidian 일간 회고 생성

**저장 경로**: `~/Documents/Obsidian-0.1/00. Inbox/03. AI Agent/sessions/reviews/daily/{TODAY}-daily-review.md`

```bash
mkdir -p "$HOME/Documents/Obsidian-0.1/00. Inbox/03. AI Agent/sessions/reviews/daily"
```

**YAML 규칙**: 2-space 들여쓰기, wikilink 따옴표 필수

**형식**:

```
---
type: daily-dev-review
aliases:
  - "{YYYY-MM-DD} 개발 회고"
author:
  - "[[이상민]]"
date created: {YYYY-MM-DD}
date modified: {YYYY-MM-DD}
tags:
  - daily-dev-review
  - auto-generated
CMDS: "[[📚 907 Technology & Development Division]]"
index: "[[🏷 Dev Reviews]]"
status: completed
project: {project}
total_sessions: {N}
total_commits: {N}
total_files_changed: {N}
total_lines_added: {N}
total_lines_deleted: {N}
---

# {YYYY-MM-DD} 일간 개발 회고

## 오늘의 세션 요약

| # | 시간 | 세션 | 핵심 작업 |
|---|------|------|----------|
| 1 | HH:mm | "[[세션 로그 제목]]" | 1줄 요약 |

## Git 커밋 히스토리

{오늘의 git log --oneline 출력}

## 코드 변경 통계

- **변경 파일**: {N}개
- **추가**: +{N}줄
- **삭제**: -{N}줄
- **커밋**: {N}개

## 오늘의 핵심 결정

- **{결정1}**: {이유}

## 오늘의 배운 점 (TIL)

- {교훈1}

## 미완료 작업

- [ ] {TODO1}

## 내일 할 일

- [ ] {내일1}

---

> [!summary] 하루 요약
> {전체 하루를 1-2문장으로 요약}
```

### 3. GitHub Devlog 생성 (git 프로젝트인 경우)

**저장 경로**: `{GIT_ROOT}/devlog/daily/{TODAY}.md`

```bash
if [ -n "$GIT_ROOT" ]; then
  mkdir -p "$GIT_ROOT/devlog/daily"
fi
```

**형식** (간결):

```markdown
# {YYYY-MM-DD} Daily Review

## Sessions
- {시간}: {세션 요약 1줄}

## Commits
{git log --oneline}

## Stats
- Files: {N}, Lines: +{N}/-{N}, Commits: {N}

## Key Decisions
- {결정1}

## TIL
- {교훈1}

## Tomorrow
- [ ] {TODO1}
```

### 4. 완료 확인

1. Obsidian 파일 존재 확인
2. (git 프로젝트) devlog 파일 존재 확인
3. YAML 2-space, wikilink 따옴표 확인

## Output

```
## 일간 개발 회고 생성 완료

- **Obsidian**: {경로}
- **Devlog**: {경로 또는 N/A}
- **날짜**: {YYYY-MM-DD}
- **세션**: {N}개 집계
- **커밋**: {N}개
- **코드**: +{N}/-{N} lines

오늘 하루 수고하셨습니다!
```
