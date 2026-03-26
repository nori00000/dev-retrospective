# 세션 회고 - 멀티 프로젝트 인프라 정비 (2026-03-25 ~ 2026-03-26)

## 메타데이터
- **기간**: 2026-03-25 ~ 2026-03-26
- **태그**: #multi-project #infrastructure #automation #github-management #cmds #branding
- **관련 레포**: chatharvest, gonggo-radar, consulting-daeyoung, openclaw-security, urban-jungle, solab-newspipe, my-context
- **커밋 수**: 3/25 약 50+ commits (4개 프로젝트), 3/26 약 10+ commits

## 세션 요약

> 3/25: 4개 프로젝트 MVP 동시 진행. 3/26: 브랜딩 브리핑 → CMDS 자동 검증 시스템 구축 → GitHub 프로젝트 관리 체계 수립 및 레포 정비

---

## 3/25 작업 내역 (GitHub 기록 기반)

### 1. ChatHarvest - 멀티플랫폼 채팅 인텔리전스 시스템
**Repo**: `nori00000/chatharvest`

MVP를 하루 만에 Phase 1~6까지 완성:
- **Phase 1**: 프로젝트 인프라 (DB, config, health, backup, launchd)
- **Phase 2**: Telegram 수집기 (실시간 + 히스토리 추출)
- **Phase 3**: KakaoTalk 수집기 (macOS DB 모니터, webhook, export parser)
- **Phase 4**: AI 분석 파이프라인 (분류기, 요약기, 키워드, 스케줄러, Obsidian 출력)
- **Phase 5**: Telegram 봇 (8개 명령어) + Streamlit 대시보드 (6개 탭) + PDF 리포트
- **Phase 6**: RAG Q&A (ChromaDB + Claude API) + FTS5 전문검색 + 실시간 키워드 알림

### 2. GongGo Radar - 공고 크롤러 확장
**Repo**: `nori00000/gonggo-radar`

크롤러 시스템 8개 → 22개 소스로 확장:
- 14개 신규 크롤러 추가 (정부/기업 공고 게시판)
- API/HTML 크롤러 분류, BaseCrawler 패턴 준수
- 3-strategy HTML 파싱 (table/list/generic)
- 228 테스트 통과, 0 실패

### 3. 대영케이블 컨설팅 (살핌)
**Repo**: `nori00000/consulting-daeyoung`

초기 커밋:
- 견적서: 생산관리시스템 구축 (파트너 특별가 1,210만원)
- 계약서: AI 코칭 서비스 (파트너 특별가 월 88만원)
- 살핌 스크립트: schedule-sentinel, weekly-review, google_calendar 모듈

### 4. OpenClaw 보안 격리 환경
**Repo**: `nori00000/openclaw-security`

Docker 격리 환경 초기 세팅:
- docker-compose.yml (OpenClaw 2026.3.23 + Ollama)
- localhost 전용 접근, 토큰/시크릿 보호

---

## 3/26 작업 내역

### 1. 브랜딩 전문가 브리핑 문서 작성

**목적**: 3개 브랜드(네이처커뮤니티, 어반정글, AIalive) 체계화를 위한 전문가 브리핑 자료 작성
**수행**: 브랜드 포트폴리오 현황, 핵심 문제점 8가지, 요청 범위, 아키텍처 모델 비교
**결과**: `Obsidian-0.1/00. Inbox/03. AI Agent/2026-03-26-브랜딩_전문가_브리핑.md`
**판단**: House of Brands + 부분적 Endorsed 구조가 적합해 보이나 전문가 검토 필요

### 2. Obsidian 파일 위치 문제 해결

**문제**: .md 파일을 홈 디렉토리에 생성하여 Obsidian에서 보이지 않음 (반복 발생)
**원인**: Obsidian은 Vault 폴더 내부 파일만 인식
**해결**: Vault 경로(`Documents/Obsidian-0.1/`) 확인 후 파일 이동
**재발 방지**: MEMORY.md에 Vault 경로 기록

### 3. CMDS 규칙 자동 강제 시스템 구축 (핵심 작업)

**문제**: CLAUDE.md에 CMDS 규칙이 상세히 문서화되어 있으나, Claude가 규칙을 읽고도 준수하지 않음
**해결**: Claude Code의 PreToolUse + PostToolUse Hooks 활용

| 파일 | 역할 |
|------|------|
| `~/.claude/hooks/cmds-pre-check.sh` | Write/Edit 전 규칙 리마인더 |
| `~/.claude/hooks/cmds-post-validate.sh` | Write/Edit 후 자동 검증 (9가지) |
| `~/.claude/settings.json` | hooks 등록 |

**검증 항목 (9가지)**:
1. YAML frontmatter 존재
2. 필수 6개 Properties (type, aliases, author, date created, date modified, tags)
3. YAML 탭 사용 금지 (2 spaces 필수)
4. Wikilinks 따옴표 필수
5. date created ISO 8601 형식
6. date modified ISO 8601 형식
7. type 값 유효성
8. author에 이상민 포함
9. tags 최소 3개 필수, 빈 태그 금지

### 4. Hooks 리팩토링

**1차 구현 → 테스트 → 회고 → 리팩토링** 사이클 수행:

| Before | After | 이유 |
|--------|-------|------|
| Pre-check 20줄 리마인더 | 7줄 핵심만 | 토큰 절약 |
| `~/.claude/` 파일에 불필요 경고 | 자동 제외 | 오탐 방지 |
| `echo -e` 사용 | bash 배열 + printf | macOS 호환성 |
| `grep -P` (Perl regex) | `printf '\t'` + 기본 grep | macOS 미지원 |
| `.obsidian/` 제외 누락 | case문으로 제외 | 시스템 파일 보호 |
| YAML 닫는 `---` 미검증 | 검증 추가 | 불완전 frontmatter 감지 |
| tags 빈 배열 통과 | 최소 3개 필수 | 의미 있는 태그 보장 |

**테스트 결과**: 22개 케이스 전부 통과
- Pre-check: 6개 (파일 유형 필터링, Vault 내/외 구분, 제외 대상)
- Post-validate: 9개 (YAML, Properties, 탭, Wikilinks, 날짜, type, author)
- Tags: 7개 (빈 배열, 1~2개, 3개 이상, 인라인/멀티라인)

### 5. GitHub 프로젝트 관리 체계 수립

**목적**: 15개+ 레포의 네이밍 혼란 해소 및 관리 체계 수립
**수행**: 전문가 관점에서 네이밍 컨벤션, 그룹화 전략, 아키텍처 다이어그램 작성

**네이밍 컨벤션 결정**:
- kebab-case 통일 (snake_case, camelCase 혼용 해소)
- 브랜드 프리픽스: solab-, client- 등으로 그룹화
- 목적이 명확한 이름 사용

**레포 리네이밍 실행**:
- `garden_platform` → `urban-jungle` (어반정글 홈페이지/쇼핑몰)
- `news-site` → `solab-newspipe` (소랩 콘텐츠 파이프라인)

**레포 정비**:
- 11개 레포에 description 일괄 추가
- 각 프로젝트 목적과 관계 명확화

### 6. solab-newspipe vs gonggo-radar 비교 분석

**목적**: 유사해 보이는 두 프로젝트의 차이점 명확화
**결론**: 병합 불가 - 완전히 다른 타겟과 목적

| | solab-newspipe | gonggo-radar |
|---|---|---|
| **브랜드** | 소랩 (AIalive) | 소랩 (AIalive) |
| **목적** | 콘텐츠 수집 → 블로그 발행 | 정부/기업 공고 수집 → 알림 |
| **타겟** | 뉴스/기술 기사 | 입찰/보조금 공고 |
| **출력** | Obsidian + 블로그 포스트 | 대시보드 + 알림 |

### 7. 초보 개발자를 위한 프로젝트 관리 규칙

3가지 심플 규칙 수립:
1. **1 프로젝트 = 1 레포** (하나의 목적, 하나의 저장소)
2. **README 먼저** (프로젝트 시작 시 README에 목적 기록)
3. **주 1회 정리** (안 쓰는 레포 archive, description 업데이트)

---

## 의사결정 기록

| 결정 | 이유 | 영향 |
|------|------|------|
| Hooks로 CMDS 강제 | CLAUDE.md 문서만으로는 AI가 규칙을 따르지 않음 | 모든 Obsidian .md 파일 |
| garden_platform → urban-jungle | 브랜드명과 일치, kebab-case 통일 | 어반정글 프로젝트 |
| news-site → solab-newspipe | 브랜드 프리픽스 + 목적 명시 | 소랩 콘텐츠 파이프라인 |
| solab-newspipe와 gonggo-radar 분리 유지 | 타겟, 목적, 출력이 완전히 다름 | 두 프로젝트 독립 운영 |
| House of Brands 구조 제안 | 3개 브랜드 간 시너지보다 독립성이 중요 | 전체 브랜드 포트폴리오 |

---

## 교훈 (Lessons Learned)

### 기술적
1. **문서만으로는 AI 행동을 강제할 수 없다** - Hooks로 자동 검증 + 피드백 루프를 만들어야 실질적으로 강제됨
2. **macOS와 Linux의 grep 차이** - `grep -P` (Perl regex)는 macOS에서 미지원. `printf` + 기본 grep으로 대체
3. **bash 산술 연산 주의** - `((PASS++))` 에서 PASS=0일 때 exit code 1 반환 (0은 falsy)
4. **PreToolUse는 간결하게** - 매번 실행되므로 출력이 길면 토큰 낭비

### 프로세스
1. **네이밍은 처음부터 신경 써야** - 나중에 바꾸면 로컬/원격/참조 모두 업데이트 필요
2. **유사 프로젝트도 목적이 다르면 분리** - solab-newspipe vs gonggo-radar처럼 겉으로 비슷해도 병합하면 복잡도만 증가
3. **회고는 작업 직후에** - 시간이 지나면 세부사항(특히 의사결정 이유)을 잊음

---

## 다음 할 일 (Follow-up)

### 즉시
- [ ] 새 세션에서 hooks 실제 동작 확인 (이번 세션에서는 세션 중 추가라 미적용)
- [ ] 브랜딩 전문가 미팅 전 체크리스트 자료 준비

### 이번 주
- [ ] 기존 Vault 문서 중 CMDS 규칙 미준수 파일 일괄 검사 스크립트 작성
- [ ] solab-newspipe 로컬 폴더 리네이밍 (GitHub은 완료)

### 나중에
- [ ] 브랜드 아키텍처 결정 후 각 브랜드별 전략 문서 작성
- [ ] 비활성 레포 아카이브 (bithumb, clode-log, Test-Project, desktop-tutorial)
- [ ] urban-jungle 프로젝트 CLAUDE.md 업데이트
