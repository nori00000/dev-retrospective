---
type: weekly-dev-review
aliases:
  - "2026-W13 주간 개발 회고"
author:
  - "[[이상민]]"
date created: 2026-03-28
date modified: 2026-03-28
tags:
  - weekly-dev-review
  - auto-generated
CMDS: "[[📚 907 Technology & Development Division]]"
index: "[[🏷 Dev Reviews]]"
status: completed
week: "W13"
year: 2026
period: "2026-03-23 ~ 2026-03-28"
total_sessions: 5
total_commits: 53
---

# 2026-W13 주간 개발 회고

> **기간**: 2026-03-23 (월) ~ 2026-03-28 (토)

## 주간 핵심 성과

1. **gonggo-radar 4-Layer 아키텍처 리팩토링** — 28개 크롤러, 6개 도메인별 AI 스코어링, 304개 테스트
2. **dev-retrospective 시스템 구축** — 9개 커맨드 + 3-Layer 회고 파이프라인 + GitHub Actions 4개 + 멀티머신 동기화
3. **5개 자동화 시스템 통합** — setup.sh 단일 부트스트랩으로 모든 인프라 연결
4. **멀티플랫폼 보완** — vault 자동탐지, Windows PowerShell 지원, 하드코딩 경로 제거
5. **신규 프로젝트 5개 초기화** — chatharvest, hometax-automation, salpim, consulting-daeyoung, openclaw-security

## 프로젝트별 진행 현황

| 프로젝트 | 커밋 | 주요 작업 |
|----------|------|----------|
| dev-retrospective | 35 | 마이그레이션, 자동화 인프라, 멀티플랫폼, 세션훅 |
| gonggo-radar | 6 | 4-Layer 리팩토링, 크롤러 8→28개, URL 수정 |
| chatharvest | 2 | MVP + Phase 5-6 |
| salpim | 3 | 초기 커밋 + HIGH 이슈 수정 + 리네이밍 |
| hometax-automation | 2 | 초기 커밋 |
| urban-jungle | 1 | 보안 강화 + 테스트 |
| solab | 1 | 검색/SEO/어드민 |
| consulting-daeyoung | 1 | 초기 커밋 |
| openclaw-security | 1 | Docker 격리 환경 |
| my-context | 1 | dev-setup.sh 부트스트랩 |
| **합계** | **53** | **10개 프로젝트** |

## 일별 활동 요약

| 날짜 | 세션 | 핵심 작업 | 커밋 |
|------|------|----------|------|
| 3/25 (화) | 2 | gonggo-radar 4-Layer 리팩토링 + 회고 시스템 구축 | ~7 |
| 3/26 (수) | 3 | GitHub Actions 인프라, dev-retrospective 마이그레이션, 체크인 첫 실행 | ~22 |
| 3/27 (목) | 1 | 멀티플랫폼 보완 (vault 자동탐지 + Windows 지원) | ~25 |
| 3/28 (금) | - | 체크인 + dirty files 정리 + 주간 회고 생성 | 1 |

### 일간 회고 링크

- "[[2026-03-25-daily-review]]" — gonggo-radar 4-Layer 대규모 리팩토링 + 회고 시스템 8커맨드 구축
- "[[2026-03-26-review]]" — 5개 자동화 시스템 통합 + 마이그레이션 + 체크인 첫 실행

### 세션 로그 링크

- "[[2026-03-26-0830-github-프로젝트-자동화-인프라]]" — RALPLAN→RALPH Phase 0-4, setup.sh 부트스트랩
- "[[2026-03-26-1030-dev-retrospective-마이그레이션]]" — clode-log→dev-retrospective, 75파일 마이그레이션
- "[[2026-03-26-1510-dev-체크인-세션로그-상세화]]" — /dev-checkin 첫 실행, 14개 백로그 파악
- "[[2026-03-27-0831-멀티플랫폼-보완-실행]]" — ralplan→ultrawork 9태스크 병렬 실행

## 기술적 결정 모음

- **파일별 심링크 전략**: 디렉토리 심링크 → 파일별 심링크 (회고+범용 커맨드 공존) (3/26)
- **하이브리드 자동화**: GH Actions(raw stats) + 로컬 크론(AI 보강) 2단계 파이프라인 (3/26)
- **단방향 동기화**: repo→vault 단방향만 (양방향 충돌 복잡도 회피) (3/26, 3/27)
- **vault-detect.sh 공유 함수**: 모든 hooks/scripts의 vault 경로 탐지를 단일 소스로 통합 (3/27)
- **hostname stagger cron**: cksum 해시 기반 0-4분 오프셋으로 멀티머신 충돌 방지 (3/27)
- **4-Layer 크롤러 아키텍처**: crawlers→analyzer→notifiers→knowledge 분리 (3/25)
- **도메인별 AI 스코어링**: 단일 프롬프트 → 6개 도메인 맞춤 프롬프트 (3/25)

## 주간 TIL Top 5

1. **ralplan 합의 플랜 + ultrawork 병렬 실행** = 높은 품질의 병렬 실행 (정확한 스펙이 핵심)
2. **config.yaml 키워드 품질 > AI 스코어링 정확도** — boost/exclude 키워드가 핵심 레버
3. **cron 환경 PATH 제한** — /usr/local/bin 미포함, 스크립트 상단 export 필수
4. **GitHub GITHUB_TOKEN은 현재 레포만** — 크로스 레포 작업에는 PAT 필요
5. **macOS/Linux stat 플래그 차이** (`-f %m` vs `-c %Y`) — 크로스 플랫폼 분기 필수

## 반복된 패턴 / 개선 포인트

### 잘한 것 (Keep)

- RALPLAN → RALPH/Ultrawork 워크플로우가 매우 효율적 (계획 품질이 실행 품질 결정)
- /dev-checkin으로 세션 시작 시 컨텍스트 빠르게 복구
- 듀얼 출력 (Obsidian 상세 + GitHub devlog 간결) 전략 유지
- 하루에 10개 프로젝트 동시 진행하면서도 체계적 추적 가능

### 개선할 것 (Improve)

- m1-pro에 unpushed 커밋/dirty files 남김 → 세션 종료 시 push 확인 루틴 필요
- 일간 회고가 3/27에 생성 안 됨 → sync-and-enrich.sh 자동 생성 검증 필요
- feature 브랜치를 remote에 push 안 한 채 방치 → 체크아웃 스킬에 경고 추가 검토

### 시도할 것 (Try)

- /dev-consult 첫 실행 — 생산성 상의로 워크플로우 최적화 도출
- /dev-radar 첫 실행 — 이번 주 사용한 기술 스택 체계적 평가
- gonggo-radar NAS Docker 배포 — 로컬 실행 → 상시 크롤링 전환

## 주간 통계

| 지표 | 값 |
|------|-----|
| 총 세션 | 5+ |
| 총 커밋 | 53 |
| 활성 프로젝트 | 10 |
| 신규 프로젝트 | 5 |
| 변경 파일 | 200+ |
| 추가 라인 | ~30,000+ |

## 다음 주 목표

1. **gonggo-radar NAS Docker 배포** — PostgreSQL + 상시 크롤링 전환
2. **salpim-web Mac Studio 배포** — Ruby/Rails + Tailscale 연동
3. **dev-retrospective 안정화** — sync-and-enrich.sh 실동작 검증, m1-pro dirty 정리
4. **/dev-consult 첫 실행** — 워크플로우 패턴 분석 및 개선점 도출
5. **GH_PAT Fine-grained 전환** — 최소 권한 원칙 적용
