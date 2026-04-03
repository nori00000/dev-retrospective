---
type: daily-dev-review
aliases:
  - "2026-04-02 개발 회고"
author:
  - "[[이상민]]"
date created: 2026-04-02
date modified: 2026-04-03
tags:
  - daily-dev-review
  - auto-generated
CMDS: "[[📚 907 Technology & Development Division]]"
index: "[[🏷 Dev Reviews]]"
status: completed
project: ai-news-pipeline
total_sessions: 2
total_commits: 8
total_files_changed: 27
total_lines_added: 4867
total_lines_deleted: 160
---

# 2026-04-02 일간 개발 회고

## 오늘의 세션 요약

| # | 시간 | 세션 | 핵심 작업 |
|---|------|------|----------|
| 1 | 21:19 | "[[2026-04-02-2119-멀티프로젝트-인프라-정비-ror-mvp]]" | 멀티프로젝트 인프라 정비, RoR MVP |
| 2 | 23:00 | "[[2026-04-02-2300-ai-news-pipeline-대규모-확장]]" | 파이프라인 대규모 확장: 6종 collector, 5종 publisher, 3종 enrichment |

## Git 커밋 히스토리

```
c73dada perf: parallelize collection (8 concurrent) + rate limiting + auto-disable
8890ee0 feat: add X (Twitter) timeline collector via twscrape
a28a921 refactor: extract shared collector helpers to _helpers.py (DRY)
3e86669 fix: code review — Korean slug, law URL encoding, settings wiring, influencer list
37e0394 feat: add enrichment columns to article_analyses
390d47b fix: test_llm_router use OLLAMA_CLASSIFY_MODEL
4afacc3 feat: add eventus, reddit collectors + law enrichment + obsidian publisher
51b6728 feat: overhaul digest — topic clustering, big news top 5, compact table
```

## 코드 변경 통계

- **변경 파일**: 27개
- **추가**: +4,867줄
- **삭제**: -160줄
- **커밋**: 8개
- **테스트**: 423 passed (3 pre-existing failures)

## 오늘의 핵심 결정

- **twscrape 선택 (X collector)**: 공식 API 유료($100/월) vs twscrape 무료+2026.04 활발 유지보수. 조건부 임포트로 미설치 시 graceful fallback
- **수집 병렬화 Semaphore(8)**: 57개 소스 순차 5-10분 → 병렬 ~1분. 8은 외부 서버 부담과 속도의 밸런스
- **Obsidian 3-tier 구조**: pipeline(AI 자동)/curated(사람)/editorial(협업) 분리로 콘텐츠 관리 체계화
- **VoidNews 역엔지니어링**: AI 전문가 큐레이터 사이트 분석으로 양질 소스 25개 빠르게 발굴

## 오늘의 배운 점 (TIL)

- Reddit은 `.rss` 경로로 공개 RSS 제공하지만 User-Agent 제한 엄격 → 브라우저 UA 필수
- X/Twitter 스크래핑 생태계 2025년 이후 급변: Nitter 사망, twscrape/twikit만 생존
- LLM 파이프라인에서 "생성은 하지만 저장은 안 되는" 숨은 데이터 유실 버그가 비용만 낭비 — DB 스키마와 프롬프트 필드 정합성 검증 필수
- `asyncio.gather + Semaphore` 패턴은 기존 순차 루프를 최소 변경으로 병렬화하는 가장 깔끔한 방법

## 미완료 작업

- [ ] twscrape 설치 + X 계정 인증 설정
- [ ] Product Hunt / HuggingFace Daily Papers RSS 추가
- [ ] 과기부/NIPA 보도자료 RSS 추가
- [ ] RSSHub 셀프호스팅 검토 (LinkedIn 등)
- [ ] Ollama 가용성 TTL 추가
- [ ] test_llm_router 3개 기존 실패 수정

## 내일 할 일

- [ ] twscrape 설치 + Tier 1 X 계정 15개 인증
- [ ] 실제 수집 사이클 실행 테스트 (57개 소스 → 다이제스트)
- [ ] sociai.org에 새 다이제스트 발행 확인
- [ ] Obsidian vault에 자동 발행 동작 확인

---

> [!summary] 하루 요약
> sociai.org AI 뉴스 파이프라인을 25개 → 57개 소스로 확장하고, collector 6종/publisher 5종/enrichment 3종 체계를 갖췄다. 병렬 수집, rate limiting, auto-disable로 운영 안정성을 확보하고, 코드 리뷰로 CRITICAL 버그 2건(한국어 slug 충돌, enrichment 데이터 유실)을 수정했다. AI 영향력자 100명 리스트를 작성하여 X timeline 수집 기반을 마련했다.
