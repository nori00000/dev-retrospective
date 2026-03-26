---
name: auto-retrospective
description: 작업 종료 시 세션 로그 + 일간 회고를 자동 실행
triggers:
  - 회고
  - 작업 끝
  - 세션 정리
  - 오늘 끝
  - 마무리
  - 세션 마무리
  - 작업 회고
  - 세션 회고
  - 오늘 회고
  - wrap
matching: fuzzy
argument-hint: "<optional: session title>"
---

# Auto Retrospective - 세션 자동 회고

사용자가 작업 종료/회고를 요청하면 다음을 **순서대로 자동 실행**합니다.

## 실행 순서

### Step 1: 세션 로그 생성 (`/session-log`)

현재 세션의 작업 내용을 분석하여:
- **Obsidian CMDS 규격 세션 로그** 생성 (상세)
- **GitHub devlog** 생성 (간결, git 프로젝트인 경우)

`/session-log` 스킬을 호출하여 실행합니다.

### Step 2: 일간 회고 (`/dev-daily`)

오늘 하루의 모든 세션과 GitHub 활동을 종합하여:
- 12개 레포 통계 확인
- 오늘 생성된 세션 로그들 종합
- AI 분석 기반 일간 리뷰 생성

`/dev-daily` 스킬을 호출하여 실행합니다.

### Step 3: 결과 보고

완료 후 사용자에게 다음을 보고:
- 생성된 파일 경로 (Obsidian + devlog)
- 오늘 활동 요약 (커밋 수, 변경 파일 수)
- 내일 할 일 목록

## 주의사항

- session-log가 먼저 완료된 후 dev-daily를 실행할 것
- Obsidian CMDS 규칙을 반드시 준수 (YAML 2-space, wikilink 따옴표 등)
- `$ARGUMENTS`가 있으면 세션 로그 제목으로 사용

## 트리거 예시

- "회고해줘" → 자동 실행
- "작업 끝" → 자동 실행
- "오늘 마무리하자" → 자동 실행
- "세션 정리해줘" → 자동 실행
