# Weekly Development Review - 주간 개발 회고

$ARGUMENTS

## Instructions

이번 주의 개발 작업을 집계하여 **주간 개발 회고**를 생성합니다.
일간 회고들 + git 히스토리를 분석하여 주간 패턴과 인사이트를 추출합니다.

### 1. 데이터 수집

#### 1.1 이번 주 일간 회고 수집

```bash
MONDAY=$(date -v-monday +%Y-%m-%d 2>/dev/null || date -d "last monday" +%Y-%m-%d)
SUNDAY=$(date +%Y-%m-%d)
WEEK_NUM=$(date +%V)
YEAR=$(date +%Y)

DAILY_DIR="$HOME/Documents/Obsidian-0.1/00. Inbox/03. AI Agent/sessions/reviews/daily"
ls "$DAILY_DIR"/ 2>/dev/null | sort
```

#### 1.2 이번 주 Git 히스토리

```bash
git log --oneline --since="$MONDAY" 2>/dev/null
git shortlog -sn --since="$MONDAY" 2>/dev/null
```

### 2. Obsidian 주간 회고 생성

**저장 경로**: `~/Documents/Obsidian-0.1/00. Inbox/03. AI Agent/sessions/reviews/weekly/{YEAR}-W{WEEK_NUM}-weekly-review.md`

```bash
mkdir -p "$HOME/Documents/Obsidian-0.1/00. Inbox/03. AI Agent/sessions/reviews/weekly"
```

**형식**:

```
---
type: weekly-dev-review
aliases:
  - "{YEAR}-W{WEEK_NUM} 주간 개발 회고"
author:
  - "[[이상민]]"
date created: {YYYY-MM-DD}
date modified: {YYYY-MM-DD}
tags:
  - weekly-dev-review
  - auto-generated
CMDS: "[[📚 907 Technology & Development Division]]"
index: "[[🏷 Dev Reviews]]"
status: completed
week: "W{WEEK_NUM}"
year: {YEAR}
period: "{MONDAY} ~ {SUNDAY}"
total_sessions: {N}
total_commits: {N}
---

# {YEAR}-W{WEEK_NUM} 주간 개발 회고

> **기간**: {MONDAY} (월) ~ {SUNDAY} (일)

## 주간 핵심 성과
1. {성과1}
2. {성과2}

## 프로젝트별 진행 현황

| 프로젝트 | 세션 | 커밋 | 변경 파일 | +/- |
|----------|------|------|----------|-----|

## 일별 활동 요약

| 날짜 | 세션 | 핵심 작업 | 커밋 |
|------|------|----------|------|

### 일간 회고 링크
- "[[{날짜}-daily-review]]" - {1줄 요약}

## 기술적 결정 모음
- **{결정}**: {이유} ({날짜})

## 주간 TIL Top 5
1. **{주제}**: {교훈}

## 반복된 패턴 / 개선 포인트

### 잘한 것 (Keep)
### 개선할 것 (Improve)
### 시도할 것 (Try)

## 다음 주 목표
1. {목표1}
```

### 3. GitHub Devlog 생성

**저장 경로**: `{GIT_ROOT}/devlog/weekly/{YEAR}-W{WEEK_NUM}.md`

## Output

```
## 주간 개발 회고 생성 완료
- **기간**: {MONDAY} ~ {SUNDAY}
- **세션**: {N}개 / **커밋**: {N}개
```
