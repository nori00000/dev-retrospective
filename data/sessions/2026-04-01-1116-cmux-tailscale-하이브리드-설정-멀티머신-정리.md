---
type: session-log
aliases:
  - "cmux + Tailscale SSH 하이브리드 설정 및 멀티머신 dirty files 정리"
author:
  - "[[이상민]]"
date created: 2026-04-01
date modified: 2026-04-01
tags:
  - session-log
  - cmux
  - tailscale
  - ssh
  - multi-machine
  - git-cleanup
CMDS: "[[📚 907 Technology & Development Division]]"
index: "[[🏷 Session Logs]]"
status: completed
machine: m1-pro
agent: claude-code
project: leesangmin
git_branch: none
review_tags:
  - infrastructure
  - terminal-tooling
  - multi-machine
  - git-maintenance
session_metrics:
  files_changed: 12
  lines_added: 580
  lines_deleted: 442
  tests_passed: "N/A"
  commits: 7
---

# cmux + Tailscale SSH 하이브리드 설정 및 멀티머신 dirty files 정리

> **세션 정보**
> - 날짜: 2026-04-01 11:16
> - 머신: m1-pro
> - 에이전트: Claude Code
> - 프로젝트: leesangmin (`/Users/leesangmin`)
> - 브랜치: none

---

## 작업 요약

	cmux(macOS GUI 터미널) + Tailscale SSH + 원격 tmux 하이브리드 워크플로우를 구축했다. cmux를 Homebrew로 설치하고, SSH config 강화, auto-attach 스크립트(ssh-tmux, cmux-remote), shell alias, cmux/tmux 설정 파일을 생성했다. 이후 /dev-checkin으로 전 머신 상태를 점검하여, m4-air(dirty 3) + m1-pro(5개 프로젝트 dirty/unpushed) 경고를 발견하고 ultrawork 모드로 전부 해결했다. m1-pro의 HTTPS remote URL도 SSH로 일괄 전환하여 인증 문제를 근본 해결했다.

## 상세 작업 내역

### 1. cmux + Tailscale SSH 하이브리드 설정

	macos-terminal-comparison-2026 가이드를 참고하여 cmux의 특성(macOS GUI 앱이라 SSH 안에서 직접 실행 불가)을 파악하고, 로컬 cmux + 원격 tmux 하이브리드 아키텍처를 설계/구현했다.

	- cmux 0.63.1 Homebrew cask 설치
	- `~/.ssh/config`에 `Host *` 기본값 블록 추가 (ServerAliveInterval 30, ServerAliveCountMax 3, AddKeysToAgent yes)
	- `~/.local/bin/ssh-tmux` 스크립트 — SSH 접속 후 tmux 세션 자동 연결
	- `~/.local/bin/cmux-remote` 스크립트 — cmux workspace 생성 + ssh-tmux 실행
	- `~/.config/cmux/config` — JetBrains Mono 14, catppuccin-mocha 테마
	- `~/.local/share/cmux/remote-tmux.conf` — 원격 머신용 tmux 설정 (catppuccin 스타일)
	- `~/.zshrc`에 alias 추가: cm, cms, cma, cmp, cmg, st

### 2. Tailscale 활성화

	Tailscale이 stopped 상태여서 `tailscale up` 실행. m4-air, m1-pro, m4-studio 3대 online 확인. mini-gateway는 offline(13일) 상태.

### 3. Dev Check-in 실행

	/dev-checkin 스킬로 전 머신 상태를 종합 점검했다. W13 주간 회고, 일간 회고, 세션 로그를 크로스 참조하여 19개 미완료 백로그와 주의사항을 정리했다.

### 4. 멀티머신 dirty files 전부 정리 (ultrawork)

	**m4-air:**
	- dev-retrospective: 세션 데이터 3파일 commit, remote HTTPS→SSH 전환, rebase 후 push

	**m1-pro (5개 프로젝트):**
	- dev-retrospective: 세션 데이터 6파일 commit + mydatabase.db gitignore, rebase 충돌 4건 해결(theirs 기준), push
	- homelab-orchestration: 12파일 리팩토링 commit + push
	- salpim: launchd plist 변경 commit, remote SSH 전환, rebase + push
	- thinkingos: devlog/ 디렉토리 commit + push, remote SSH 전환
	- my-context: .omc/ gitignore 추가, push (회고 브랜치)

### 5. 세션 핸드오프 문서 생성

	다음 세션에서 이어서 작업할 수 있도록 컨텍스트 전달 문서를 작성했다.

## 변경된 파일

| 파일 | 변경 유형 | 설명 |
|------|----------|------|
| `~/.ssh/config` | 수정 | Host * 기본값 블록 추가 |
| `~/.local/bin/ssh-tmux` | 생성 | SSH + tmux auto-attach 스크립트 |
| `~/.local/bin/cmux-remote` | 생성 | cmux workspace 런처 |
| `~/.config/cmux/config` | 생성 | cmux 설정 (Ghostty 문법) |
| `~/.local/share/cmux/remote-tmux.conf` | 생성 | 원격 tmux 설정 |
| `~/.zshrc` | 수정 | cmux/ssh alias 추가 |
| m4-air: dev-retrospective | commit+push | 세션 데이터 3파일, remote SSH 전환 |
| m1-pro: dev-retrospective | commit+push | 세션 데이터 6파일, gitignore, 충돌 해결 |
| m1-pro: homelab-orchestration | commit+push | 12파일 리팩토링 |
| m1-pro: salpim | commit+push | launchd plist, remote SSH 전환 |
| m1-pro: thinkingos | commit+push | devlog/ 추가, remote SSH 전환 |
| m1-pro: my-context | commit+push | .omc/ gitignore |

## 핵심 결정

- **로컬 cmux + 원격 tmux 하이브리드 아키텍처**: cmux는 macOS GUI 앱이라 SSH 내부에서 실행 불가. cmux의 vertical tabs, notification ring, splits를 로컬에서 활용하고, 원격 tmux가 세션 유지를 담당하는 분리 구조 채택
- **HTTPS→SSH remote 일괄 전환**: m1-pro에서 git push 시 HTTPS 인증 실패(-25308 keychain 에러) 반복 → 3개 프로젝트의 remote URL을 SSH로 전환하여 근본 해결
- **rebase 충돌 theirs 기준 해결**: dev-retrospective의 자동 동기화 데이터(reviews) 충돌은 remote가 최신이므로 theirs 기준으로 일관 처리

## 배운 점 (TIL)

- cmux는 Ghostty의 libghostty 렌더링 엔진 기반 macOS 터미널로, AI agent 오케스트레이션에 특화 (notification ring, socket API)
- m1-pro의 git credential 문제(-25308)는 macOS keychain에서 HTTPS 토큰을 못 읽는 것 → SSH key 방식이 서버 환경에서 더 안정적
- `git rebase --continue`에 `--no-edit` 옵션 없음 → `GIT_EDITOR=true git rebase --continue`로 대체
- 멀티머신 dirty files 관리는 세션 종료 시 반드시 push까지 확인해야 누적 안 됨

## 미완료 / 후속 작업

- [ ] cmux 실동작 테스트 — cms/cma/cmp 명령으로 원격 접속 검증
- [ ] remote-tmux.conf 배포 — `for h in m4-air m1-pro m4-studio; do scp ~/.local/share/cmux/remote-tmux.conf $h:~/.tmux.conf; done`
- [ ] mini-gateway 물리적 전원 켜기 후 상태 확인 (13일 offline)
- [ ] salpim-web Mac Studio 배포 (W13 이월)
- [ ] gonggo-radar NAS Docker 배포 (W13 이월)

---

> [!info] 관련 노트
> - "[[2026-W13-weekly-review]]"
> - "[[2026-03-30-0905-session-skeleton]]"
