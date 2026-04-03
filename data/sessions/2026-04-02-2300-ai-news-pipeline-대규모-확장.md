---
type: session-log
aliases:
  - "ai-news-pipeline 대규모 확장"
author:
  - "[[이상민]]"
date created: 2026-04-02
date modified: 2026-04-03
tags:
  - session-log
  - ai-news-pipeline
  - sociai
  - collector
  - publisher
  - enrichment
CMDS: "[[📚 907 Technology & Development Division]]"
index: "[[🏷 Session Logs]]"
status: completed
machine: m4-studio
agent: claude-code
project: ai-news-pipeline
git_branch: main
review_tags:
  - architecture
  - crawler
  - refactoring
  - testing
  - data-pipeline
  - social-media
session_metrics:
  files_changed: 27
  lines_added: 4867
  lines_deleted: 160
  tests_passed: 423
  commits: 7
---

# ai-news-pipeline 대규모 확장

> **세션 정보**
> - 날짜: 2026-04-02 23:00 ~ 2026-04-03 05:43
> - 머신: m4-studio
> - 에이전트: Claude Code (Opus 4.6)
> - 프로젝트: ai-news-pipeline (`/Users/leesangmin/Projects/ai-news-pipeline`)
> - 브랜치: main

---

## 작업 요약

sociai.org AI 뉴스 파이프라인을 대규모 확장. 핸드오프 문서 기반으로 3개 신규 모듈(Reddit collector, event-us scraper, Obsidian publisher, 법률 enrichment) 구현 후, VoidNews 역엔지니어링으로 25개 추가 소스를 발굴하여 DB 등록. AI 영향력자 100명 리스트 작성. 코드 리뷰로 CRITICAL 버그(한국어 slug 충돌, enrichment 데이터 유실) 수정. 수집 병렬화(8 concurrent) + rate limiting + auto-disable로 성능/안정성 개선.

## 상세 작업 내역

### 1. 핸드오프 기반 신규 모듈 구현 (병렬 4개 에이전트)

- **Reddit RSS collector** (`src/collectors/reddit.py`): feedparser 기반, min_score 필터, link/self-post URL 해석, 44 테스트
- **event-us.kr scraper** (`src/collectors/eventus.py`): regex HTML 파싱, 한국어 날짜 처리, 키워드별 페이지네이션, 36 테스트
- **Obsidian vault publisher** (`src/publishers/obsidian.py`): pipeline/curated/editorial 구조, YAML 프론트매터, 51 테스트
- **법률 enrichment** (`src/enrichments/law_enrichment.py`): 법제처 API 연동, 키워드 추출 → 관련 조항 첨부, 24 테스트

### 2. 파이프라인 연동

- `daily.py` composer에 법률 enrichment (`⚖️ 관련 법령` 섹션) 연동
- `routes.py` `_publish_to_all()`에 Obsidian publisher 연동
- `.env` / `config.py`에 `OBSIDIAN_VAULT_PATH`, `LAW_OC` 설정 추가

### 3. VoidNews 역엔지니어링 + 소스 확장

- voidnews-archive.vercel.app W12/W13 분석 → 핵심 X 계정 11개, 블로그/뉴스레터 소스 식별
- DB에 25개 신규 RSS 소스 등록 (Fortune, Wired, VentureBeat, NVIDIA, Anthropic, Mistral, 뉴스레터 7개, 한국 매체 2개 등)
- Reddit 3개, YouTube 3개, event-us 1개 소스 등록

### 4. AI 영향력자 100명 리스트

- `docs/ai-influencers-100.md` 작성 (8개 카테고리, X 계정 85개)
- Tier 1/2/3 스크래핑 우선순위 가이드 포함

### 5. 코드 리뷰 + CRITICAL 버그 수정

- **한국어 slug 충돌** (CRITICAL): `_slugify`에 `가-힣` + sha256 폴백
- **enrichment 데이터 유실** (CRITICAL): DB 마이그레이션으로 3개 컬럼 추가 (`structural_analysis`, `social_sector_impact`, `collaboration_opportunities`), processor에서 저장
- 법률 URL 인코딩, config placeholder 체크, frontmatter 개행 처리

### 6. 아키텍처 개선

- **수집 병렬화**: `asyncio.gather` + `Semaphore(8)` (5-10분 → ~1분)
- **Rate limiting**: Reddit 2s, event-us 1.5s/2s inter-request delay
- **Auto-disable**: 10회 연속 실패 시 소스 자동 비활성화
- **헬퍼 DRY 리팩토링**: `_helpers.py`로 3개 파일 중복 제거

### 7. X Timeline collector

- `src/collectors/x_timeline.py`: twscrape 기반, 조건부 임포트(미설치 시 graceful fallback)
- multi-account, min_likes 필터, 2s inter-account delay, 40 테스트

## 변경된 파일

| 파일 | 변경 유형 | 설명 |
|------|----------|------|
| `src/collectors/reddit.py` | 생성 | Reddit RSS collector |
| `src/collectors/eventus.py` | 생성 | event-us.kr HTML scraper |
| `src/collectors/x_timeline.py` | 생성 | X timeline collector (twscrape) |
| `src/collectors/_helpers.py` | 생성 | 공유 헬퍼 (DRY 리팩토링) |
| `src/collectors/__init__.py` | 수정 | 3개 collector 등록 |
| `src/collectors/rss.py` | 수정 | 헬퍼 → _helpers.py 이동 |
| `src/collectors/youtube.py` | 수정 | 헬퍼 → _helpers.py 이동 |
| `src/publishers/obsidian.py` | 생성 | Obsidian vault publisher |
| `src/publishers/__init__.py` | 수정 | ObsidianPublisher 등록 |
| `src/enrichments/law_enrichment.py` | 생성 | 법제처 API 연동 enrichment |
| `src/composers/daily.py` | 수정 | 법률 enrichment + settings.law_oc 연동 |
| `src/composers/templates/daily_ko.md.j2` | 수정 | law_section 블록 추가 |
| `src/api/routes.py` | 수정 | Obsidian publisher 연동 |
| `src/config.py` | 수정 | obsidian_vault_path, law_oc, obsidian placeholder check |
| `src/models.py` | 수정 | ArticleAnalysis에 3개 enrichment 컬럼 추가 |
| `src/processors/summarizer.py` | 수정 | SummaryResult에 structural_analysis 필드 |
| `src/workers/processor.py` | 수정 | 3개 enrichment 필드 저장 |
| `src/workers/collector.py` | 수정 | 병렬화 + auto-disable |
| `alembic/versions/6fa9d9961eee_*.py` | 생성 | DB 마이그레이션 |
| `.env.example` | 수정 | 새 설정 문서화 |
| `docs/ai-influencers-100.md` | 생성 | AI 영향력자 100명 |
| `tests/test_reddit.py` | 생성 | 44 tests |
| `tests/test_eventus.py` | 생성 | 36 tests |
| `tests/test_obsidian.py` | 생성 | 52 tests |
| `tests/test_law_enrichment.py` | 생성 | 24 tests |
| `tests/test_x_timeline.py` | 생성 | 40 tests |

## 핵심 결정

- **twscrape 선택 (X collector)**: 공식 API 유료($100/월), twscrape는 무료+활발히 유지보수(2026.04). 조건부 임포트로 미설치 시에도 파이프라인 동작
- **regex HTML 파싱 (event-us)**: beautifulsoup4 의존성 추가 없이 regex로 구현. 기술 부채로 인지하되, 현재 동작에 충분
- **Obsidian vault 구조**: pipeline(AI 자동) / curated(사람) / editorial(협업) 3-tier 분리로 콘텐츠 관리 체계화
- **수집 병렬화 Semaphore(8)**: 너무 높으면 외부 서버 부담, 너무 낮으면 느림. 8은 57개 소스에 적절한 밸런스
- **enrichment 데이터 유실 수정**: LLM이 생성한 structural_analysis 등이 DB에 저장 안 되던 기존 CRITICAL 버그 발견 및 수정

## 배운 점 (TIL)

- Reddit은 `.rss` 경로로 공개 RSS를 제공하지만 User-Agent 제한이 엄격 → 브라우저 UA 필수
- X/Twitter 스크래핑 생태계는 2025년 이후 급변: Nitter 사망, twscrape/twikit만 생존
- VoidNews 같은 전문 큐레이터 사이트를 역엔지니어링하면 양질의 소스를 빠르게 발굴 가능
- Alembic autogenerate는 새 컬럼 감지가 정확하지만, server_default 변경 감지에 false positive 발생
- `asyncio.gather + Semaphore` 패턴으로 기존 순차 루프를 최소 코드 변경으로 병렬화 가능

## 미완료 / 후속 작업

- [ ] twscrape 설치 + X 계정 인증 설정 (실제 X 계정 필요)
- [ ] Product Hunt RSS 소스 추가
- [ ] HuggingFace Daily Papers RSS 소스 추가
- [ ] 과기부/NIPA 보도자료 RSS 추가
- [ ] RSSHub 셀프호스팅 검토 (LinkedIn 등 추가 소스)
- [ ] Ollama 가용성 TTL 추가 (sticky cache → 5분 재확인)
- [ ] 기존 test_llm_router 3개 실패 수정

---

> [!info] 관련 노트
> - "[[sociai.org]]"
> - "[[ai-news-pipeline]]"
> - "[[AI 영향력자 100명]]"
