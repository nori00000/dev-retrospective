# dev-retrospective 마이그레이션

- **날짜**: 2026-03-26
- **프로젝트**: dev-retrospective
- **브랜치**: main

## 작업 요약

`clode-log` 리포를 `dev-retrospective`로 리네임 후, Obsidian vault에 흩어진 개발 회고 시스템(9 커맨드, 2 훅, 크론)을 독립 git 리포로 마이그레이션. 75파일(+5,622줄) 단일 커밋. 디렉토리 심링크 → 파일별 심링크 전환. GitHub Actions 4개 + 로컬 크론 3개 하이브리드 자동화 구축. 심링크 리셋 근본 원인(옛 setup.sh) 수정.

## 변경된 파일

| 파일 | 변경 | 설명 |
|------|------|------|
| `commands/*.md` (9개) | 생성 | 회고 커맨드 마이그레이션 |
| `hooks/*.sh` (2개) | 생성 | 세션 라이프사이클 훅 |
| `scripts/*.sh` (5개) | 생성 | setup, aggregate-stats, sync-and-enrich 등 |
| `.github/workflows/*.yml` (4개) | 생성 | 스케줄 기반 자동 회고 |
| `data/sessions/*.md` (45개) | 생성 | 기존 세션 로그 마이그레이션 |
| `config/tracked-repos.json` | 생성 | 추적 리포 목록 |
| `docs/`, `README.md` 등 | 생성 | 프로젝트 문서 |

## 핵심 결정

- 파일별 심링크: 회고 커맨드와 범용 커맨드 공존을 위해 디렉토리 심링크 대신 파일별 심링크
- 하이브리드 자동화: GH Actions(raw stats) + 로컬 크론(AI 보강) 2단계 파이프라인
- 옛 setup.sh를 리다이렉트로 교체하여 심링크 리셋 재발 방지

## 배운 점 (TIL)

- zsh globbing과 공백 경로 충돌 → `bash -c` 래핑 필요
- 여러 시스템이 같은 디렉토리 관리 시 충돌 → 단일 소스 통일 필수
- 백그라운드 에이전트 Bash 권한 이슈 → 파일 복사는 메인 컨텍스트에서 수행

## 후속 작업

- [ ] GH Actions workflow_dispatch 수동 테스트
- [ ] 멀티머신 setup.sh 검증
- [ ] tracked-repos.json 실제 리포 목록 업데이트
- [ ] sync-and-enrich.sh 실동작 검증
