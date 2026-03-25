# Monthly Development Review - 월간 개발 회고

$ARGUMENTS

## Instructions

이번 달의 개발 작업을 집계하여 **월간 개발 회고**를 생성합니다.
주간 회고들 + 전체 git 히스토리를 분석하여 월간 트렌드와 전략적 인사이트를 추출합니다.

### 1. 데이터 수집

```bash
YEAR=$(date +%Y)
MONTH=$(date +%m)
WEEKLY_DIR="$HOME/Documents/Obsidian-0.1/00. Inbox/03. AI Agent/sessions/reviews/weekly"
DAILY_DIR="$HOME/Documents/Obsidian-0.1/00. Inbox/03. AI Agent/sessions/reviews/daily"

ls "$WEEKLY_DIR"/${YEAR}-W* 2>/dev/null | sort
ls "$DAILY_DIR"/${YEAR}-${MONTH}-* 2>/dev/null | sort
git log --oneline --since="${YEAR}-${MONTH}-01" 2>/dev/null
```

### 2. Obsidian 월간 회고 생성

**저장 경로**: `~/Documents/Obsidian-0.1/00. Inbox/03. AI Agent/sessions/reviews/monthly/{YEAR}-{MONTH}-monthly-review.md`

```bash
mkdir -p "$HOME/Documents/Obsidian-0.1/00. Inbox/03. AI Agent/sessions/reviews/monthly"
```

**형식**:

```
---
type: monthly-dev-review
aliases:
  - "{YEAR}년 {MONTH}월 개발 회고"
author:
  - "[[이상민]]"
date created: {YYYY-MM-DD}
date modified: {YYYY-MM-DD}
tags:
  - monthly-dev-review
  - auto-generated
CMDS: "[[📚 907 Technology & Development Division]]"
index: "[[🏷 Dev Reviews]]"
status: completed
year: {YEAR}
month: {MONTH}
total_sessions: {N}
total_commits: {N}
total_files_changed: {N}
total_lines_added: {N}
total_lines_deleted: {N}
---

# {YEAR}년 {MONTH}월 월간 개발 회고

## 이번 달 가장 큰 성과

## 주간 회고 요약

| 주차 | 기간 | 핵심 성과 | 세션 | 커밋 |
|------|------|----------|------|------|

## 프로젝트 진행 타임라인

## 기술 스택 변화
### 새로 도입한 것
### 버린 것 / 대체한 것

## 아키텍처 결정 레코드 (ADR 요약)

## 월간 TIL Top 10

## 개발 프로세스 개선 제안
### 유지 (Keep)
### 개선 (Improve)
### 도입 (Adopt)
### 폐기 (Drop)

## 다음 달 목표
```

### 3. GitHub Devlog 생성

**저장 경로**: `{GIT_ROOT}/devlog/monthly/{YEAR}-{MONTH}.md`

## Output

```
## 월간 개발 회고 생성 완료
- **기간**: {YEAR}년 {MONTH}월
```
