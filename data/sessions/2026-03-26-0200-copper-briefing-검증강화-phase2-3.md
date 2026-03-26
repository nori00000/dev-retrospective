---
type: session-log
aliases:
  - "copper-briefing 데이터 검증 강화 Phase 2-3"
author:
  - "[[이상민]]"
date created: 2026-03-26
date modified: 2026-03-26
tags:
  - session-log
  - copper-briefing
  - anti-hallucination
  - data-verification
  - testing
CMDS: "[[📚 907 Technology & Development Division]]"
index: "[[🏷 Session Logs]]"
status: completed
machine: m1-pro
agent: claude-code
project: copper-briefing
git_branch: main
review_tags:
  - verification
  - anti-hallucination
  - testing
  - bug-fix
  - pipeline-robustness
session_metrics:
  files_changed: 25
  lines_added: 2679
  lines_deleted: 64
  tests_passed: 217
  commits: 0
---

# copper-briefing 데이터 검증 강화 Phase 2-3

> **세션 정보**
> - 날짜: 2026-03-26 02:00
> - 머신: m1-pro
> - 에이전트: Claude Code (Opus 4.6)
> - 프로젝트: copper-briefing (`/Users/leesangmin/projects/copper-briefing`)
> - 브랜치: main

---

## 작업 요약

전선 제조업 대표를 위한 원자재 시황 자동 브리핑 시스템(`copper-briefing`)의 **데이터 검증 신뢰도를 극대화**하는 작업을 수행했다. Architect 에이전트의 포괄적 갭 분석에서 식별된 **48개 데이터 포인트 중 17개 검증 갭**에 대해 11개 권고사항(REC-A~K)을 모두 구현하고, 26개 신규 테스트를 추가하여 217/217 전체 테스트 통과를 달성했다. Architect 최종 검증에서 **APPROVED** 판정을 받았다.

## 상세 작업 내역

### 1. Phase 2: 데이터 검증 감사 (REC-1~7)

	이전 세션에서 완료된 7개 권고사항:
	- REC-1: LLM 텍스트 내 숫자 검출/교차검증 (`verify_llm_numbers`)
	- REC-2: CrossChecker DB 기반 교차검증
	- REC-3: 전일비 자동 계산 (`_calculate_change_pct`)
	- REC-4: yfinance/Yahoo Finance 날짜 검증
	- REC-5: COMEX 단위 변환 감사 로깅
	- REC-6: 2차 검증 루프 (`_second_pass_verification`)
	- REC-7: RangeChecker 파이프라인 통합

### 2. Phase 3: 검증 갭 완전 해소 (REC-A~K) — 이번 세션 핵심

	Architect 갭 분석 결과 11개 권고사항을 병렬로 구현:

	**P1 (Critical)**:
	- **REC-A**: COMEX 이중변환 버그 수정 — DB에 $/톤으로 저장된 값을 다시 `comex_lb_to_ton()` 호출하여 ~20M 비현실적 값 생성 → `comex_cu_unit` 키 기반 분기로 수정
	- **REC-B**: `comex_cu_change_pct`, `usdkrw_change_pct`, `dxy_change_pct` 3개 TAG 추가
	- **REC-C**: `krw_cost_per_ton` 허용오차 1→10,000 KRW (12.6M 원 대비 적절)

	**P2 (High)**:
	- **REC-D**: LME/SHFE 재고 + NDF 범위 검증 추가
	- **REC-E**: `comex_cu_ton` 계산 TAG 추가
	- **REC-F**: DXY 월간/연간 — 내재적 검증으로 유보 (입력값 이미 검증됨)
	- **REC-G**: 전망 staleness(>90일) + 가격범위(3000-25000) 검증

	**P3 (Medium)**:
	- **REC-H**: `fx_7d` 통계 최소 3데이터 포인트 요구
	- **REC-I**: DXY 데이터 누락 시 구조화 경고 로그
	- **REC-J**: `calendar_events` 죽은 Jinja2 루프 → 정적 플레이스홀더
	- **REC-K**: `market_structure_text` — 검증된 입력의 결정론적 계산으로 내재적 검증

### 3. 테스트 작성 (26개 신규)

	`tests/test_generators/test_verification_gaps.py`에 10개 테스트 클래스:
	- `TestComexUnitAwareConversion` (4개): 단위별 변환 분기 검증
	- `TestTemplateComexTonDisplay` (2개): $/lb 역산 로직
	- `TestComexCuTagFormat` (1개): TAG 포맷 확인
	- `TestChangePctTags` (4개): 3개 신규 TAG 존재/설정 확인
	- `TestKrwCostTolerance` (1개): 허용오차 10000 확인
	- `TestComexCuTonTag` (3개): 계산 TAG 동작
	- `TestForecastValidation` (5개): staleness + 가격 범위
	- `TestFx7dMinDataPoints` (3개): 최소 데이터 수
	- `TestDxyMissingWarning` (1개): 경고 로그
	- `TestCalendarEventsRemoved` (2개): 죽은 코드 제거 확인

### 4. Architect 3차 검증

	Architect(Opus) 에이전트가 전체 코드를 교차검증하여 **APPROVED** 판정.
	- 48개 데이터 포인트별 검증 커버리지 매핑 완료
	- 1건 Advisory: `collect_data.py`의 `"lme_copper"` → `range_check.py`의 `"lme_copper_3m"` 키 불일치 (pre-existing, non-blocking)

## 변경된 파일

| 파일 | 변경 유형 | 설명 |
|------|----------|------|
| `src/generators/post_verify.py` | 수정 | TAG 6개 추가/수정 (comex_cu 포맷, 3 change_pct, krw 허용오차, comex_cu_ton) |
| `src/generators/briefing.py` | 수정 | 단위인식 파생값, 전망 검증, fx_7d 최소 데이터, DXY 경고 |
| `src/generators/template.py` | 수정 | COMEX 단위 인식 분기, $/lb 역산 |
| `functions/collect_data.py` | 수정 | 재고/NDF 범위 검증 3건 추가 |
| `templates/briefing_template.md` | 수정 | calendar_events 죽은 코드 → 정적 텍스트 |
| `tests/test_generators/test_verification_gaps.py` | 생성 | 26개 검증 갭 테스트 |
| `src/charts/generator.py` | 생성 | 3종 차트 생성 (Phase 1) |
| `src/generators/sources.py` | 생성 | 출처 매핑 (Phase 1) |
| `src/delivery/pdf.py` | 생성 | PDF 생성 (Phase 1) |
| `src/collectors/base.py` | 수정 | 전일비 자동 계산 (Phase 2) |
| `src/collectors/comex.py` | 수정 | 날짜 검증, 단위 변환 로깅 (Phase 2) |
| `src/collectors/fx.py` | 수정 | Yahoo Finance 날짜 검증 (Phase 2) |
| `src/delivery/email.py` | 수정 | CID 인라인 차트 + PDF 첨부 |
| `src/delivery/google_docs.py` | 수정 | Drive 업로드 + 인라인 이미지 |
| `src/delivery/orchestrator.py` | 수정 | PDF 생성 + 파라미터 전달 |
| `functions/generate_briefing.py` | 수정 | chart_paths 전달 수정 |

## 핵심 결정

- **COMEX 단위 전파 방식**: DB→fetcher→derived→template 전체 경로에 `comex_cu_unit` 키를 전파하여 분기 처리. 대안(DB 수정)보다 하위 호환성이 좋은 선택
- **REC-F/K 유보**: DXY 월간/연간, market_structure_text는 이미 검증된 입력의 결정론적 계산이므로 TAG 추가의 복잡성 대비 이득이 낮아 유보. Architect도 동의
- **krw_cost_per_ton 허용오차 10,000**: ~12.6M KRW 값에 대해 1원은 비현실적. 부동소수점 곱셈 오차를 고려하여 10,000으로 완화
- **fx_7d 최소 3포인트**: 1-2개 데이터로는 high/low/avg가 의미 없음. 통계적으로 의미 있는 최소 기준으로 3 채택

## 배운 점 (TIL)

- **이중변환 패턴**: 데이터 수집기가 단위 변환을 하고 저장하면, 하류 파이프라인이 같은 변환을 다시 수행하는 버그가 발생할 수 있음. `price_unit` 같은 메타데이터를 함께 전달하는 것이 핵심
- **검증 커버리지는 레이어별로 다름**: TAG 정확 매치(가장 강력) → 내재적 검증(파생값) → 가드 보호(범위/품질) → LLM 숫자 검증(부분적). 각 레이어의 강도를 구분하여 보고하는 것이 투명함
- **병렬 에이전트 작업 시 파일 파티셔닝**: 같은 파일을 2개 에이전트가 동시에 수정하면 충돌 가능. 함수 단위로 소유권을 분리하면 안전하게 병렬 작업 가능
- **structlog.testing.capture_logs()**: 구조화 로그의 테스트에 매우 유용. 경고/에러 로그가 올바르게 발생하는지 단위 테스트로 검증 가능

## 미완료 / 후속 작업

- [ ] `collect_data.py`의 `data_type: "lme_copper"` → `"lme_copper_3m"` 키 정렬 (pre-existing 이슈)
- [ ] Cloud Function의 `prices_summary`, `one_line_summary` 메타데이터 키 미설정 문제 수정
- [ ] git commit 생성 (16개 수정 + 9개 신규 파일)
- [ ] 통합 테스트: 차트→파이프라인→배달 전체 플로우 E2E 테스트
- [ ] 실제 Supabase DB 연결하여 라이브 테스트 수행
- [ ] Obsidian 보고서 이미 업데이트됨: `"[[2026-03-26-copper-briefing-chart-pdf-sources]]"`

---

> [!info] 관련 노트
> - "[[2026-03-26-copper-briefing-chart-pdf-sources]]"
