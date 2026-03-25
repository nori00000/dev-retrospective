# dev-retrospective

개발 회고 자동화 시스템 - Claude Code 슬래시 커맨드 + GitHub Actions + 로컬 AI 보강

## 개요

개발 세션 로깅, 일간/주간/월간 회고를 자동화하는 시스템입니다.

- **9개 Claude Code 슬래시 커맨드**: 세션 로그, 일간/주간/월간 회고, 체크인, 상담, 트렌드, 발견 기록, 설정
- **GitHub Actions**: 스케줄 기반 자동 통계 수집
- **로컬 AI 보강**: Claude CLI로 raw stats를 한국어 리뷰로 변환
- **멀티머신 동기화**: git 기반, setup.sh 한 번으로 새 머신 부트스트랩

## 구조

```
dev-retrospective/
├── commands/           # Claude Code 슬래시 커맨드 (9개)
├── hooks/              # 세션 백업/복원 훅
├── scripts/            # 자동화 스크립트
├── data/
│   ├── sessions/       # 세션 로그
│   └── reviews/        # 회고 결과
├── config/             # 설정 (tracked-repos.json)
├── .github/workflows/  # GitHub Actions
├── archive/            # clode-log v0.1 원본
└── docs/               # 문서
```

## 설치

```bash
git clone https://github.com/nori00000/dev-retrospective.git ~/.dev-retrospective
bash ~/.dev-retrospective/scripts/setup.sh
```

## 커맨드

| 커맨드 | 설명 |
|--------|------|
| `/session-log` | 세션 로그 생성 (Obsidian + GitHub devlog) |
| `/dev-daily` | 일간 개발 회고 |
| `/dev-weekly` | 주간 개발 회고 |
| `/dev-monthly` | 월간 개발 회고 |
| `/dev-checkin` | 세션 시작 체크인 (과거 교훈 로드) |
| `/dev-consult` | 개발 생산성 상의 |
| `/dev-radar` | 기술 트렌드 탐색 |
| `/dev-inbox` | 기술 발견 기록 |
| `/dev-setup` | 시스템 설정/동기화 |

## 자동화

### GitHub Actions (Phase 1: 자동 통계 수집)
- **Daily**: 매일 22:00 KST - tracked repos 통계 수집
- **Weekly**: 매주 일요일 21:00 KST
- **Monthly**: 매월 1일 21:00 KST

### 로컬 AI 보강 (Phase 2)
- 30분마다 git pull → raw stats 발견 → Claude CLI로 AI 리뷰 생성

### 크론탭
```bash
# Git 동기화 (30분마다)
*/30 * * * * cd ~/.dev-retrospective && git pull --ff-only

# 세션 데이터 자동 커밋 (매시간)
0 * * * * cd ~/.dev-retrospective && git add -A data/ && git diff --cached --quiet || (git commit -m "auto: sync" && git push)

# AI 보강 (22:30)
30 22 * * * bash ~/.dev-retrospective/scripts/sync-and-enrich.sh
```

## 히스토리

- **v0.1** (2025-07-15): clode-log 초기 프로토타입
- **v1.0** (2026-03-26): dev-retrospective로 리네임, 풀 시스템 구축

## 라이센스

MIT
