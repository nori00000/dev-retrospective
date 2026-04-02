# Changelog

## [1.0.0] - 2026-03-26

### Added
- 10개 Claude Code 슬래시 커맨드 마이그레이션
- GitHub Actions 워크플로우 (daily/weekly/monthly stats + sync notify)
- 로컬 AI 보강 스크립트 (sync-and-enrich.sh)
- 멀티머신 setup.sh (파일별 심링크 방식)
- 세션 데이터 46개 파일 마이그레이션
- tracked-repos.json 설정
- Obsidian 하위 호환 심링크

### Changed
- 리포 이름: clode-log → dev-retrospective
- 동기화 방식: Google Drive 심링크 → git 기반
- 심링크 전략: 디렉토리 통째 → 파일별 심링크
- 크론 경로: vault 직접 참조 → 리포 내 스크립트

### Preserved
- clode-log v0.1 원본 → archive/clode-log-v0.1/

## [0.1.0] - 2025-07-15

### Added
- 초기 프로토타입 (clode-log)
- 기본 테스트 구조
