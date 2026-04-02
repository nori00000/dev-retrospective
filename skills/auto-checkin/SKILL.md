---
name: auto-checkin
description: 멀티머신 체크인 — 머신 식별, 핸드오프 확인, 할 일 목록 표시
triggers:
  - 체크인
  - checkin
  - check-in
  - 작업 시작
  - 시작하자
  - 출근
matching: fuzzy
---

# Auto Check-in (멀티머신 핸드오프)

사용자가 체크인/작업 시작을 요청하면 아래 절차를 **순서대로 자동 실행**합니다.
추가 확인 없이 바로 실행합니다.

## Step 1: 머신 식별

```bash
MACHINE=$(scutil --get ComputerName 2>/dev/null || hostname -s)
```

머신 이름을 확인하고, 역할을 표시:
- **m4-studio**: 128GB M4 Max, 공장/서버 (상시 가동)
- **m4-air**: M4, 이동용 리모컨
- **m1-pro**: 16GB M1, 주력 작업대

## Step 2: 마지막 세션 확인

`~/.dev-retrospective/data/machines/{MACHINE}/last_session.json` 파일을 읽어서:
- 마지막 세션 시각
- 작업했던 프로젝트
- 미푸시 커밋, 더티 파일 수

## Step 3: 핸드오프 문서 확인

`~/projects/homelab-orchestration/handoffs/` 디렉토리에서:
1. `git -C ~/projects/homelab-orchestration pull --rebase` (최신 핸드오프 가져오기, 실패해도 계속)
2. 최근 핸드오프 파일(최대 3개)을 읽고, **이 머신에 해당하는 할 일**만 추출
3. 다른 머신에서 넘긴 작업이 있으면 강조 표시

## Step 4: 이 머신의 할 일 목록

`~/projects/homelab-orchestration/tasks/{MACHINE}.md` 파일을 읽어서:
- `- [ ]` (미완료) 항목만 추출하여 번호 매긴 표로 표시
- `- [x]` (완료) 항목은 개수만 요약

## Step 5: 현재 프로젝트 상태

현재 working directory가 git 프로젝트이면:
- `git status --short` (더티 파일)
- `git log --oneline -5` (최근 커밋)
- 브랜치 상태 (detached HEAD 등 이상 상태 경고)

## 출력 형식

```
## 체크인 — {MACHINE} ({날짜})

**역할:** {역할 설명}
**마지막 세션:** {시각} ({프로젝트}, {시간 전})

### 핸드오프 수신
> {다른 머신에서 넘긴 내용 요약, 없으면 "없음"}

### 할 일 목록 ({미완료}개 남음 / {완료}개 완료)

| # | 작업 | 비고 |
|---|------|------|
| 1 | ... | ... |

### 현재 프로젝트: {프로젝트명}
- 브랜치: {branch}
- 상태: {클린/더티}
```

## 주의사항

- homelab-orchestration이 없으면 경고만 표시하고 나머지 단계 계속 진행
- last_session.json이 없으면 "첫 체크인" 으로 표시
- 핸드오프/태스크 파일이 없으면 해당 섹션 생략
- git pull 실패해도 로컬 파일로 진행
