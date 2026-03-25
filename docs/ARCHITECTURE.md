# Architecture

## 시스템 개요

dev-retrospective는 3-Layer Hybrid 아키텍처로 동작합니다.

### Layer 1: Claude Code 커맨드 (인터랙티브)
사용자가 `/session-log`, `/dev-daily` 등을 실행하면 Claude Code가 세션 로그와 회고를 생성합니다.
- 출력: `data/sessions/`, `data/reviews/`
- 자동 커밋: 크론으로 매시간

### Layer 2: GitHub Actions (자동, 신뢰성)
스케줄에 따라 tracked-repos.json의 리포 통계를 수집합니다.
- 스크립트: `scripts/aggregate-stats.sh`
- 출력: `data/reviews/{type}/{date}-stats-raw.md`
- Claude CLI 불필요 (순수 gh api + jq)

### Layer 3: 로컬 AI 보강 (자동, AI)
GitHub Actions가 생성한 raw stats를 Claude CLI로 분석합니다.
- 스크립트: `scripts/sync-and-enrich.sh`
- 입력: `*-stats-raw.md`
- 출력: `*-review.md`
- 트리거: 크론 (22:30) 또는 git pull 후 자동 감지

## 심링크 전략

```
~/.claude/commands/          (실제 디렉토리)
├── session-log.md → ~/.dev-retrospective/commands/session-log.md  (심링크)
├── dev-daily.md   → ~/.dev-retrospective/commands/dev-daily.md    (심링크)
├── ...            (회고 커맨드 9개: 리포에서 심링크)
├── commit.md      (직접 파일, 범용 커맨드)
└── explain.md     (직접 파일, 범용 커맨드)
```

## 멀티머신 동기화

1. 새 머신에서 `setup.sh` 실행
2. 리포 clone → 심링크 생성 → 크론 등록
3. 이후 git pull/push로 자동 동기화
