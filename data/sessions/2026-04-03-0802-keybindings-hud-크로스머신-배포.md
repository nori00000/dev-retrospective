---
type: session-log
aliases:
  - "keybindings + HUD 크로스머신 배포"
author:
  - "[[이상민]]"
date created: 2026-04-03
date modified: 2026-04-03
tags:
  - session-log
  - cross-machine
  - dev-environment
  - claude-code
CMDS: "[[📚 907 Technology & Development Division]]"
index: "[[🏷 Session Logs]]"
status: completed
machine: m4-studio
agent: claude-code
project: openclaw
git_branch: main
review_tags:
  - devtools
  - cross-machine-sync
  - configuration
session_metrics:
  files_changed: 8
  lines_added: 160
  lines_deleted: 11
  tests_passed: "N/A"
  commits: 0
---

# keybindings + HUD 크로스머신 배포

> **세션 정보**
> - 날짜: 2026-04-03 07:49
> - 머신: m4-studio
> - 에이전트: Claude Code
> - 프로젝트: openclaw (`/Users/leesangmin/openclaw`)
> - 브랜치: main

---

## 작업 요약

- `Ctrl+Shift+Z` 모델 전환 단축키가 터미널 SIGTSTP와 충돌하는 문제 해결 → `Ctrl+Shift+M`으로 변경
- keybindings.json, HUD 스크립트 3개 (omc-hud.mjs, daily-budget.mjs, usage-advice.mjs), settings.json을 3대 머신(m4-studio, m4-air, m1-pro)에 배포
- dev-retrospective에 configs/claude/ 디렉토리 추가하여 git 기반 크로스머신 동기화 체계 구축
- dev-setup.sh에 4b/4c 단계 추가 (심링크 우선, fallback 직접 생성) + Gist 업데이트
- cc() 함수에 usage-advice.mjs 호출 추가하여 시작시 토큰 예산 대시보드 자동 표시

## 상세 작업 내역

### 1. 모델 전환 단축키 충돌 해결

`Ctrl+Shift+Z`가 터미널의 SIGTSTP(프로세스 일시정지) 시그널로 해석되어 Claude Code가 suspend되는 문제 발견. `Ctrl+Shift+M` (M=Model)로 변경하고, 한글 입력 대응으로 `Ctrl+Shift+ㅡ` 추가.

### 2. usage-advice.mjs 단축키 표기 수정

usage-advice.mjs 내 `Shift+Z→모델 전환` 표기를 `Ctrl+Shift+M→모델 전환`으로 수정.

### 3. 크로스머신 배포 전략 수립 및 실행

`dev-retrospective/configs/claude/` 에 설정 파일을 git 커밋하고, 각 머신에서 심링크로 연결하는 방식 채택. 3대 모두 scp + ssh로 배포 완료.

### 4. dev-setup.sh 확장 + Gist 업데이트

새 머신 셋업 시에도 keybindings, HUD, usage-advice가 자동 배포되도록 dev-setup.sh에 4b (keybindings 심링크), 4c (HUD 심링크) 단계 추가. settings.json에 statusLine, autoMemory, autoDream 설정도 포함. `gh gist edit`로 Gist도 업데이트.

## 변경된 파일

| 파일 | 변경 유형 | 설명 |
|------|----------|------|
| `~/.claude/keybindings.json` | 수정→심링크 | Ctrl+Shift+M 모델 전환 |
| `~/.claude/hud/omc-hud.mjs` | 심링크 | OMC statusline 래퍼 |
| `~/.claude/hud/daily-budget.mjs` | 심링크 | 일일 토큰 예산 HUD |
| `~/.claude/hud/usage-advice.mjs` | 수정→심링크 | Shift+Z→Ctrl+Shift+M 수정 |
| `~/.claude/scripts/dev-setup.sh` | 수정 | 4b/4c 단계 추가, cc() 함수에 usage-advice 호출 |
| `~/.dev-retrospective/configs/claude/` | 생성 | 크로스머신 설정 소스 |
| 원격 m4-air settings.json | 수정 | statusLine + autoMemory 추가 |
| 원격 m1-pro settings.json | 수정 | statusLine + autoMemory 추가 |

## 핵심 결정

- **Ctrl+Shift+M 채택**: 터미널 시그널과 충돌 없는 키 조합, M=Model로 직관적
- **dev-retrospective 심링크 방식**: git으로 버전관리 + 심링크로 자동 반영, hooks 패턴과 일관성 유지
- **dev-setup.sh에 fallback 포함**: dev-retrospective가 없는 완전 새 머신에서도 inline으로 파일 생성

## 배운 점 (TIL)

- `Ctrl+Shift+Z`는 대부분의 터미널에서 `Ctrl+Z`(SIGTSTP)와 동일하게 해석됨 — 터미널 시그널 관련 키 조합은 keybinding으로 사용 불가
- SSH non-login shell에서 `node`가 PATH에 없을 수 있음 — interactive shell(cc 함수)에서는 정상 작동
- `gh gist edit`로 Gist를 CLI에서 바로 업데이트 가능

## 미완료 / 후속 작업

- [ ] m4-air `.zshrc` PATH에 `/opt/homebrew/bin` 추가 (SSH non-login shell에서도 node 사용 가능하도록)
- [ ] 설정 변경 시 자동 push 스크립트 또는 LaunchD sync 확장 고려

---

> [!info] 관련 노트
> - "[[dev-setup.sh 부트스트랩 스크립트]]"
> - "[[멀티머신 개발환경 동기화]]"
