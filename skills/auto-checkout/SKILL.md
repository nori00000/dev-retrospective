---
name: auto-checkout
description: 작업 종료 시 /session-log 자동 실행
triggers:
  - 체크아웃
  - checkout
  - check-out
  - 퇴근
  - 로그아웃
matching: fuzzy
---

# Auto Check-out

사용자가 체크아웃/퇴근을 요청하면 `/session-log` 스킬을 자동으로 실행합니다.

## 실행

`/session-log` 스킬을 즉시 호출하세요. 추가 확인 없이 바로 실행합니다.
