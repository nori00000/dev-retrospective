---
type: session-log
aliases:
  - "Cross-Machine Session Logging System 구축"
author: "[[Claude Code]]"
date created: 2026-02-16
date modified: 2026-02-16
tags:
  - session-log
  - homelab
  - orchestration
  - cross-machine
CMDS: "[[📚 900 System]]"
index: "[[🏷 Session Logs]]"
status: complete
machine: m1-pro
agent: claude-code
project: homelab-orchestration
git_branch: main
---
# Cross-Machine Session Logging System 구축

## Summary

M1 Pro + M4 Air 듀얼 맥 홈랩에서 Claude Code 설정/스킬/훅을 자동 전파하고, Telegram OpenClaw 세션을 Obsidian 노트로 자동 기록하는 시스템을 구축했다.

## What Was Built

| Phase | Description | Status |
|-------|------------|--------|
| Phase 1 | M4 Air 설정 동기화 (settings.json 머지, hooks, Obsidian dirs) | Done |
| Phase 2 | Config 자동 전파 (settings-merge.sh, orch-config-sync.sh, launchd) | Done |
| Phase 3 | Telegram 세션 로깅 (JSONL 파서, CMDS Obsidian 노트, launchd) | Done |
| Phase 4 | Bootstrap 툴링 (원커맨드 새 머신 셋업 + --verify) | Done |
| Phase 5 | E2E 검증 + Architect 승인 | Done |

## Files Created

1. **settings-merge.sh** - per-key 전략의 지능형 JSON 머지 (source-wins, target-wins, union)
2. **orch-config-sync.sh** - 5분 주기 launchd 데몬, M1 Pro → M4 Air 설정 푸시
3. **telegram-session-logger.sh** - OpenClaw JSONL → CMDS Obsidian 노트 변환
4. **bootstrap-machine.sh** - 원커맨드 새 머신 셋업 (`--verify` 모드 포함)
5. **away-setup.sh** - config-sync 데몬 추가

## Running Daemons (Both Machines)

| Daemon | Interval | Purpose |
|--------|----------|---------|
| com.homelab.config-sync | 5min | M1 Pro 설정 자동 전파 |
| com.homelab.telegram-logger | 30min | OpenClaw 세션 → Obsidian |
| com.homelab.file-sync | 5min | 프로젝트 파일 동기화 |
| com.homelab.task-queue | 5min | 양방향 태스크 큐 |
| com.homelab.status-reporter | 5min | 하트비트 리포팅 |
| com.homelab.nas-mount | 5min | NAS 마운트 |

## Key Learnings (TIL)

### Critical: rsync --delete 양방향 레이스 컨디션
- `rsync --delete` + 양방향 동기화 = 새 파일이 상대 머신 데몬에 의해 삭제됨
- 이 세션에서 3번 파일이 삭제되었고 3번 재생성함
- **교훈**: 양방향 sync에서 `--delete` 절대 사용 금지

### Bash: ((M++)) under set -e
- `((M++))` when M=0 → exit code 1 → `set -e`가 스크립트 종료
- **수정**: `M=$((M + 1))` 사용

### Bash: pipefail + grep SIGPIPE
- `launchctl list | grep` → grep이 먼저 종료 → SIGPIPE → pipefail 실패
- **수정**: 변수에 캡처 후 grep (`DAEMONS=$(launchctl list); echo "$DAEMONS" | grep`)

### macOS: ~/Documents/ FDA 보호
- SSH로 ~/Documents/ 쓰기 불가 (Full Disk Access 필요)
- LaunchAgent는 사용자 세션 권한으로 쓰기 가능

### macOS: cron 대신 LaunchAgent
- macOS cron은 FDA 필요 + 레거시
- LaunchAgent이 Apple 공식 스케줄링 메커니즘

## Bugs Fixed

1. `((M++))` arithmetic bug in bootstrap-machine.sh & telegram-session-logger.sh
2. pipefail + SIGPIPE in bootstrap-machine.sh verify mode
3. Hardcoded `machine: m4-air` in telegram-session-logger.sh
4. file-sync race condition (daemons unloaded, files recreated, reloaded)

## Next Session TODO

| Priority | Task |
|----------|------|
| **P0** | `orch-file-sync.sh:29` `--delete` 플래그 제거/교체 |
| **P1** | telegram-logger를 bootstrap verify + away-setup AGENTS에 추가 |
| **P1** | telegram-logger 세션 종료 시간 계산 |
| **P2** | 프로젝트 README.md 생성 |
| **P2** | enabledPlugins 머지 동작 문서화 |

## Session Stats

- Duration: ~3 hours
- Scripts created: 5
- LaunchAgents deployed: 2
- Bugs fixed: 4
- Machines configured: 2
- Git commit: `00a5e3e` (pushed to origin/main)

## Related

- "[[🏷 Session Logs]]"
- "[[homelab-orchestration]]"
