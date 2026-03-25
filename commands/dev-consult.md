# Dev Consult - 개발 생산성 상의

$ARGUMENTS

## Instructions

개발 프로세스 자체를 회고하고 개선하는 **메타 회고** 세션입니다.
축적된 회고 데이터를 분석하여 개발 생산성 향상을 위한 제안을 하고,
사용자와 대화형으로 개선점을 합의합니다.

### 1. 회고 데이터 종합 분석

```bash
SESSIONS_DIR="$HOME/Documents/Obsidian-0.1/00. Inbox/03. AI Agent/sessions"
DAILY_DIR="$HOME/Documents/Obsidian-0.1/00. Inbox/03. AI Agent/sessions/reviews/daily"
WEEKLY_DIR="$HOME/Documents/Obsidian-0.1/00. Inbox/03. AI Agent/sessions/reviews/weekly"
MONTHLY_DIR="$HOME/Documents/Obsidian-0.1/00. Inbox/03. AI Agent/sessions/reviews/monthly"
INBOX_DIR="$HOME/Documents/Obsidian-0.1/00. Inbox/03. AI Agent/sessions/reviews/inbox"
RADAR_DIR="$HOME/Documents/Obsidian-0.1/00. Inbox/03. AI Agent/sessions/reviews/radar"

# 최근 세션 로그 (20개)
ls "$SESSIONS_DIR"/*.md 2>/dev/null | sort -r | head -20
# 최근 일간 회고 (14개)
ls "$DAILY_DIR"/*.md 2>/dev/null | sort -r | head -14
# 최근 주간 회고 (4개)
ls "$WEEKLY_DIR"/*.md 2>/dev/null | sort -r | head -4
# dev-inbox 미검토 항목
cat "$INBOX_DIR/dev-inbox.md" 2>/dev/null
# 최근 tech radar
ls "$RADAR_DIR"/*.md 2>/dev/null | sort -r | head -1
```

### 2. 패턴 분석

**시간 패턴**: 생산적 요일/시간, 세션 길이
**작업 패턴**: 구현/디버깅/리팩토링/문서화 비율
**품질 패턴**: 테스트, 반복 버그, 기술 부채
**학습 패턴**: 반복 실수, 새 기술 도입 빈도

### 3. 사용자와 대화형 상의

AskUserQuestion으로:
1. 현재 가장 큰 페인포인트
2. 개선 우선순위 (분석에서 도출된 제안들)
3. 다음 기간 실험 주제
4. dev-inbox 미검토 항목 리뷰

### 4. 합의 결과 기록

- 프로젝트 CLAUDE.md 업데이트
- 글로벌 메모리 업데이트
- 실행 항목(TODO) 생성

### 5. 컨설팅 리포트 저장

**저장 경로**: `~/Documents/Obsidian-0.1/00. Inbox/03. AI Agent/sessions/reviews/consult/{YYYY-MM-DD}-dev-consult.md`

```
---
type: dev-consult
aliases:
  - "{YYYY-MM-DD} 개발 생산성 상의"
author:
  - "[[이상민]]"
date created: {YYYY-MM-DD}
date modified: {YYYY-MM-DD}
tags:
  - dev-consult
  - productivity
CMDS: "[[📚 907 Technology & Development Division]]"
index: "[[🏷 Dev Reviews]]"
status: completed
---

# {YYYY-MM-DD} 개발 생산성 상의

## SWOT 분석
### 강점 / 약점 / 기회 / 위협

## 합의된 개선 사항
### 즉시 적용 / 다음 주 실험 / 장기 검토

## 실행 항목
- [ ] {실행1} - 기한: {날짜}
```

## Output

```
## 개발 생산성 상의 완료
- **분석 기간**: {기간}
- **합의된 개선**: {N}개
- **실행 항목**: {N}개
```
