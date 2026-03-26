---
type: session-log
aliases:
  - "dev-retrospective 마이그레이션"
author:
  - "[[이상민]]"
date created: 2026-03-26
date modified: 2026-03-26
tags:
  - session-log
  - migration
  - infrastructure
  - automation
CMDS: "[[📚 907 Technology & Development Division]]"
index: "[[🏷 Session Logs]]"
status: completed
machine: m4-air
agent: claude-code
project: dev-retrospective
git_branch: main
review_tags:
  - migration
  - infrastructure
  - github-actions
  - symlink
  - automation
  - cron
session_metrics:
  files_changed: 81
  lines_added: 6116
  lines_deleted: 1
  tests_passed: "N/A"
  commits: 8
---

# dev-retrospective 마이그레이션

> **세션 정보**
> - 날짜: 2026-03-26 10:30
> - 머신: m4-air
> - 에이전트: Claude Code
> - 프로젝트: dev-retrospective (`~/.dev-retrospective`)
> - 브랜치: main

---

## 작업 요약

기존 Obsidian vault에 흩어져 있던 개발 회고 시스템(9개 커맨드, 2개 훅, 크론 자동화)을 독립 GitHub 리포(`nori00000/dev-retrospective`)로 마이그레이션했다. `clode-log` 리포를 리네임하고, 75개 파일(+5,622줄)을 단일 커밋으로 마이그레이션했다. 심링크 전략을 디렉토리 레벨에서 파일 레벨로 전환하고, GitHub Actions 4개 + 로컬 크론 3개의 하이브리드 자동화를 구축했다. 심링크 리셋 근본 원인을 추적하여 해결했다.

## 상세 작업 내역

### 1. GitHub 리포 리네임 및 클론

`gh repo rename`으로 `clode-log` → `dev-retrospective`로 변경. `~/.dev-retrospective/`에 클론하고 전체 디렉토리 구조(`commands/`, `hooks/`, `scripts/`, `data/`, `archive/`, `config/`, `.github/workflows/`, `docs/`)를 생성했다.

### 2. 데이터 마이그레이션 (75파일, +5,622줄)

4개 병렬 에이전트로 작업을 분배:
	- **에이전트 1** (파일 마이그레이션): Bash 권한 문제로 실패 → 메인 컨텍스트에서 수동 수행
	- **에이전트 2** (문서): README, CHANGELOG, LICENSE, ARCHITECTURE.md 등 7개 파일 생성
	- **에이전트 3** (GitHub Actions): review-daily/weekly/monthly.yml + sync-notify.yml 4개 워크플로우 생성
	- **에이전트 4** (스크립트): aggregate-stats.sh, sync-and-enrich.sh, setup.sh 생성

세션 파일 45개, 커맨드 9개, 훅 2개, 기존 스크립트 2개를 vault에서 리포로 복사. `clode-log` 원본은 `archive/clode-log-v0.1/`에 보존.

### 3. 심링크 전략 전환

기존: `~/.claude/commands/` → vault 디렉토리 전체 심링크
변경: `~/.claude/commands/` 실제 디렉토리 + 파일별 심링크 9개

```
~/.claude/commands/
├── dev-daily.md → ~/.dev-retrospective/commands/dev-daily.md (심링크)
├── session-log.md → ~/.dev-retrospective/commands/session-log.md (심링크)
├── ... (회고 커맨드 9개)
├── commit.md (일반 커맨드, 평문 파일)
└── ... (일반 커맨드 9개)
```

### 4. 크론탭 + GitHub Actions 하이브리드 자동화

**크론 (로컬)**:
	- `*/30 * * * *` - git pull 동기화
	- `0 * * * *` - 세션 데이터 자동 커밋+푸시
	- `30 22 * * *` - AI 보강 (sync-and-enrich.sh)

**GitHub Actions (원격)**:
	- 매일 22:00 KST - daily stats 수집
	- 매주 일요일 21:00 KST - weekly stats
	- 매월 1일 21:00 KST - monthly stats
	- push 시 sync-notify

### 5. 심링크 리셋 근본 원인 수정

`/dev-daily` 실행 시 "Unknown skill" 에러 발생. 조사 결과, vault의 옛 `setup.sh`가 `~/.claude/commands/`를 디렉토리 심링크로 덮어쓰는 것이 원인. 옛 `setup.sh`를 새 리포의 `setup.sh`로 리다이렉트하는 thin wrapper로 교체하여 재발 방지.

### 6. Obsidian 하위 호환성

`~/Documents/Obsidian-0.1/00. Inbox/03. AI Agent/sessions` → `~/.dev-retrospective/data/sessions` 심링크로 Obsidian Dataview, 백링크 등 정상 작동 보장.

## 변경된 파일

| 파일 | 변경 유형 | 설명 |
|------|----------|------|
| `commands/*.md` (9개) | 생성 | vault에서 회고 커맨드 복사 |
| `hooks/session-backup.sh` | 생성 | 세션 종료 훅 복사 |
| `hooks/session-restore.sh` | 생성 | 세션 시작 훅 복사 |
| `scripts/setup.sh` | 생성 | 새 부트스트랩 스크립트 |
| `scripts/aggregate-stats.sh` | 생성 | GH Actions용 통계 수집 |
| `scripts/sync-and-enrich.sh` | 생성 | 로컬 AI 보강 |
| `scripts/dev-review-cron.sh` | 생성 | 크론 엔트리포인트 복사 |
| `.github/workflows/*.yml` (4개) | 생성 | 스케줄 기반 자동 회고 |
| `config/tracked-repos.json` | 생성 | 추적 리포 목록 |
| `data/sessions/*.md` (45개) | 생성 | 기존 세션 로그 마이그레이션 |
| `README.md`, `CHANGELOG.md` 등 | 생성 | 프로젝트 문서 |
| `archive/clode-log-v0.1/` | 생성 | 원본 보존 |
| vault `setup.sh` | 수정 | 리다이렉트로 교체 |

## 핵심 결정

- **파일별 심링크 전략**: 디렉토리 심링크는 회고 커맨드와 범용 커맨드가 공존할 수 없어서 파일별로 전환. 범용 커맨드는 평문 파일, 회고 커맨드만 심링크.
- **하이브리드 자동화**: GH Actions에서 Claude CLI 실행 불가 → Actions는 raw stats만 생성, 로컬 크론이 AI 보강하는 2단계 파이프라인
- **옛 setup.sh 리다이렉트**: 삭제 대신 리다이렉트로 처리하여, 다른 머신에서 옛 경로로 실행해도 새 setup으로 안내
- **Obsidian 심링크 호환**: sessions 디렉토리를 리포로 이동 후 vault에서 심링크로 연결, Dataview 쿼리 등 기존 기능 유지

## 배운 점 (TIL)

- **zsh globbing + 공백 경로 충돌**: `cp ~/path with spaces/*.md`는 zsh에서 실패함. `bash -c 'cp "$HOME/path with spaces/"*.md dest/'`로 해결해야 함
- **백그라운드 에이전트 Bash 권한**: Task 에이전트에서 Bash 실행이 권한 거부될 수 있음 → 파일 복사 같은 작업은 메인 컨텍스트에서 직접 수행이 안전
- **심링크 경쟁 조건**: 여러 시스템(Google Drive, setup 스크립트, 크론)이 같은 디렉토리를 관리하면 충돌 발생 → 단일 소스(리포 setup.sh)로 통일 필수
- **`ln -sf`는 기존 파일 덮어씀**: 심링크 재생성 시 안전하게 사용 가능

## 미완료 / 후속 작업

- [ ] GH Actions 수동 트리거 테스트: `workflow_dispatch`로 daily stats 생성 확인
- [ ] 다른 머신에서 `setup.sh` 실행하여 멀티머신 동기화 검증
- [ ] `tracked-repos.json` 업데이트 (현재 3개 → 실제 활성 리포 반영)
- [ ] AI 보강 스크립트 (`sync-and-enrich.sh`) 실제 동작 검증

---

> [!info] 관련 노트
> - "[[🏷 Session Logs]]"
> - "[[📚 907 Technology & Development Division]]"
